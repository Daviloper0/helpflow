{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module API.Server (server) where

import Servant

import API.API
import API.Register
import API.Login
import API.Ticket
import API.AssignTicket
import API.SolveTicket
import Application.Identity.LoginRequest

server :: Server API
server =
    registerHandler
    :<|> loginHandler
    :<|> ticketHandler
    :<|> assignTicketHandler
    :<|> solveTicketHandler