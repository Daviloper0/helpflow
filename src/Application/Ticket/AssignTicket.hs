{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Application.Ticket.AssignTicket (AssignTicketRequest(..), assignTicket) where

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

-- deveria achar outro nome 
assignTicket :: TicketId -> UserId -> IO (Maybe (Ticket 'InProgress))
assignTicket ticketId userId = do
    ticket <- findOpenTicket ticketId

    case ticket of
        Nothing ->
            pure Nothing

        Just openTicket -> do
            user <- findUserById userId

            case user of
                Nothing ->
                    pure Nothing

                Just technician ->
                    case makeTechnicianId technician of
                        Nothing ->
                            pure Nothing

                        Just technicianId -> do
                            let inProgressTicket = assignTicketToTechnician technicianId openTicket

                            updateTicket inProgressTicket
                            pure (Just inProgressTicket)