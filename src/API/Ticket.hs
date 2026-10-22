{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module API.Ticket (ticketHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import API.TicketResponse
import API.ErrorResponse

import Application.Ticket.CreateTicket

ticketHandler :: CreateTicketRequest -> Handler TicketResponse
ticketHandler request = do
    result <- liftIO (createTicket request)

    case result of
        Left InvalidUserId ->
            throwError (errorResponse err400 "INVALID_USER_ID" "Invalid userId")

        Left InvalidPriority ->
            throwError (errorResponse err400 "INVALID_PRIORITY" "Invalid priority, valid values are: Low, Normal, High")

        Right ticket ->
            pure (ticketToResponse ticket)
