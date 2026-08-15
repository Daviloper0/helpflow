-- API/SolveTicket.hs

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module API.SolveTicket (solveTicketHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import Application.Ticket.SolveTicket
import API.TicketResponse
import API.ErrorResponse

import Domain.Ticket.Ticket
{-Parecido com o resto, para variar-}

solveTicketHandler :: TicketId -> Handler TicketResponse
solveTicketHandler ticketId = do
    result <- liftIO (completeTicket ticketId)

    case result of
        Left TicketNotFound ->
            throwError (errorResponse err404 "TICKET_NOT_FOUND" "Ticket not found")

        Left TicketNotInProgress ->
            throwError (errorResponse err409 "TICKET_NOT_IN_PROGRESS" "Ticket isn't assigned yet, it's still open")

        Right solvedTicket ->
            pure (ticketSolvedToResponse solvedTicket)