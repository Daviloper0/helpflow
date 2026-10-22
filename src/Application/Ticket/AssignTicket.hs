{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Application.Ticket.AssignTicket (AssignTicketRequest(..), AssignTicketError(..), assignTicket) where

import Data.Aeson

import Infrastructure.Identity.UserRepository
import Infrastructure.Ticket.TicketRepository

import Domain.Ticket.Ticket
import Domain.Identity.User
import Domain.Identity.UserId


import Data.Text (Text)

data AssignTicketRequest = AssignTicketRequest
    {
        requestTechnicianId :: Text
    }
    deriving (Eq, Show)

instance FromJSON AssignTicketRequest where
    parseJSON = withObject "AssignTicketRequest" $ \jsonPayload -> do
        technicianId <- jsonPayload .: "technicianId"
        pure (AssignTicketRequest technicianId)

-- deixando erro mais explíciito
data AssignTicketError =
      TicketNotAvailable
    | UserNotFound
    | UserNotTechnician
    | InvalidTechnicianId
    deriving (Eq, Show)

-- deveria achar outro nome
-- tive que trocar a assinatura porque agora tem os casos de erro
assignTicket :: TicketId -> Text -> IO (Either AssignTicketError (Ticket 'InProgress))
assignTicket ticketId technicianIdText =
    case makeUserId technicianIdText of
        Nothing -> pure (Left InvalidTechnicianId)
        Just technicianUserId -> do
            ticket <- findOpenTicket ticketId

            case ticket of
                Nothing ->
                    pure (Left TicketNotAvailable)

                Just openTicket -> do
                    user <- findUserById technicianUserId

                    case user of
                        Nothing ->
                            pure (Left UserNotFound)

                        Just technician ->
                            case makeTechnicianId technician of
                                Nothing ->
                                    pure (Left UserNotTechnician)

                                Just technicianId -> do
                                    let inProgressTicket = assignTicketToTechnician technicianId openTicket

                                    updateTicket inProgressTicket
                                    pure (Right inProgressTicket)
