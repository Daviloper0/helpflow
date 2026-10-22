-- API/SolveTicket.hs

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module API.SolveTicket (solveTicketHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import API.TicketResponse
import API.ErrorResponse

import Application.Ticket.SolveTicket

import Domain.Ticket.Ticket

import Data.Text (Text)
{-Parecido com o resto, para variar-}

solveTicketHandler :: Text -> Handler TicketResponse
solveTicketHandler ticketIdText = do
    ticketId <- case makeTicketIdFromText ticketIdText of
        Nothing -> throwError (errorResponse err400 "INVALID_TICKET_ID" "Invalid ticketId")
        Just tid -> pure tid

    result <- liftIO (completeTicket ticketId)

    case result of
        Left TicketNotFound ->
            throwError (errorResponse err404 "TICKET_NOT_FOUND" "Ticket not found")

        Left TicketNotInProgress ->
            throwError (errorResponse err409 "TICKET_NOT_IN_PROGRESS" "Ticket isn't assigned yet, it's still open")

        Right solvedTicket ->
            pure (ticketSolvedToResponse solvedTicket)