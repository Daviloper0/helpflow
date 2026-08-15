{-# LANGUAGE DataKinds #-}

module API.AssignTicket (assignTicketHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import Application.Ticket.AssignTicket
import API.TicketResponse

import Domain.Ticket.Ticket

-- similar aos outros também
assignTicketHandler :: TicketId -> AssignTicketRequest -> Handler TicketResponse
assignTicketHandler ticketId request = do
    result <- liftIO (assignTicket ticketId (requestTechnicianId request))

    case result of
        Nothing ->
            throwError err404

        Just inProgressTicket ->
            pure (ticketInProgressToResponse inProgressTicket)