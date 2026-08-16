{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module API.AssignTicket (assignTicketHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import API.TicketResponse
import API.ErrorResponse

import Application.Ticket.AssignTicket

import Domain.Ticket.Ticket

-- similar aos outros também
assignTicketHandler :: TicketId -> AssignTicketRequest -> Handler TicketResponse
assignTicketHandler ticketId request = do
    result <- liftIO (assignTicket ticketId (requestTechnicianId request))
    {-Antes estava com erro genérico 404, mas é melhor ser mais específico-}
    case result of
        Left TicketNotAvailable ->
            throwError (errorResponse err409 "TICKET_NOT_AVAILABLE" "Ticket is not available, maybe it doesn't exist or it's already assigned")
        
        Left UserNotFound ->
            throwError (errorResponse err404 "USER_NOT_FOUND" "User not found")

        Left UserNotTechnician ->
            throwError (errorResponse err400 "USER_NOT_TECHNICIAN" "User is not a technician")

        Right inProgressTicket ->
            pure (ticketInProgressToResponse inProgressTicket)