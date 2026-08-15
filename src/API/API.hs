{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module API.API (API) where

import Servant
import Application.Identity.RegisterRequest
import Application.Identity.LoginRequest
import Application.Ticket.CreateTicket

import API.RegisterResponse
import API.LoginResponse
import API.TicketResponse

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