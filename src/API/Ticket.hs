{-# LANGUAGE DataKinds #-}

module API.Ticket (ticketHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import API.TicketResponse

import Application.Ticket.CreateTicket

--explicação do codigo no register.hs

ticketHandler :: CreateTicketRequest -> Handler TicketResponse
ticketHandler request = do
    ticket <- liftIO (createTicket request)

    pure (ticketToResponse ticket)