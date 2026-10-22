{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module API.API (API) where

import Servant
import Data.Text (Text)

import API.RegisterResponse
import API.LoginResponse
import API.TicketResponse

import Application.Identity.RegisterRequest
import Application.Identity.LoginRequest
import Application.Ticket.CreateTicket
import Application.Ticket.AssignTicket

import Domain.Ticket.Ticket
import Domain.Identity.UserId

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

    :<|> "ticket" -- PATCH /ticket/{ticketId}/assign
            :> Capture "ticketId" Text
            :> "assign"
            :> ReqBody '[JSON] AssignTicketRequest
            :> Patch '[JSON] TicketResponse

    :<|> "ticket" -- PATCH /ticket/{ticketId}/solve
            :> Capture "ticketId" Text
            :> "solve"
            :> Patch '[JSON] TicketResponse
    :<|> "user" -- PATCH /user/{administratorId}/promote/{targetUserId}
            :> Capture "administratorId" Text
            :> "promote"
            :> Capture "targetUserId" Text
            :> Patch '[JSON] RegisterResponse

    :<|> "user" -- PATCH /user/{administratorId}/demote/{targetUserId}
            :> Capture "administratorId" Text
            :> "demote"
            :> Capture "targetUserId" Text
            :> Patch '[JSON] RegisterResponse
