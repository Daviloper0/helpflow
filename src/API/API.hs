{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module API.API (API) where

import Servant
import Application.Identity.RegisterRequest
import Application.Identity.LoginRequest
import Application.Ticket.CreateTicket
import Application.Ticket.AssignTicket
import Domain.Ticket.Ticket

import API.RegisterResponse
import API.LoginResponse
import API.TicketResponse
import API.SolveTicket

type API =
         "register" -- POST /register
            :> ReqBody '[JSON] RegisterRequest
            :> Post '[JSON] RegisterResponse

    :<|> "login" -- POST /login
            :> ReqBody '[JSON] LoginRequest
            :> Post '[JSON] LoginResponse
    
    :<|> "ticket" -- POST /ticket 
            :> ReqBody '[JSON] CreateTicketRequest 
            :> Post '[JSON] TicketResponse

    :<|> "ticket" -- PATCH /ticket/:ticketId/assign
            :> Capture "ticketId" TicketId
            :> "assign"
            :> ReqBody '[JSON] AssignTicketRequest
            :> Patch '[JSON] TicketResponse
            
    :<|> "ticket" -- PATCH /ticket/:ticketId/solve
            :> Capture "ticketId" TicketId
            :> "solve"
            :> Patch '[JSON] TicketResponse