{-# LANGUAGE DataKinds #-}

module API.Ticket (ticketHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import Application.Ticket.CreateTicket
import API.TicketResponse

--explicação do codigo no register.hs

ticketHandler :: CreateTicketRequest -> Handler TicketResponse
ticketHandler request = do
    ticket <- liftIO (createTicket request)

    pure (ticketToResponse ticket)