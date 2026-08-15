{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Application.Ticket.AssignTicket (AssignTicketRequest(..), AssignTicketError(..), assignTicket) where

import Data.Aeson

import Domain.Ticket.Ticket
import Domain.Identity.User
import Domain.Identity.UserId
import Infrastructure.Identity.UserRepository
import Infrastructure.Ticket.TicketRepository


data AssignTicketRequest = AssignTicketRequest
    {
        requestTechnicianId :: UserId
    }
    deriving (Eq, Show)

instance FromJSON AssignTicketRequest where
    parseJSON = withObject "AssignTicketRequest" $ \object -> do
        technicianIdText <- object .: "technicianId"

        case makeUserId technicianIdText of
            Nothing -> fail "Invalid technicianId,"

            Just technicianId -> pure (AssignTicketRequest technicianId)
-- deixando erro mais explíciito
data AssignTicketError =
      TicketNotAvailable
    | UserNotFound
    | UserNotTechnician
    deriving (Eq, Show)

-- deveria achar outro nome 
-- tive que trocar a assinatura porque agora tem os casos de erro
assignTicket :: TicketId -> UserId -> IO (Either AssignTicketError (Ticket 'InProgress))
assignTicket ticketId userId = do
    ticket <- findOpenTicket ticketId

    case ticket of
        Nothing ->
            pure (Left TicketNotAvailable)

        Just openTicket -> do
            user <- findUserById userId

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
