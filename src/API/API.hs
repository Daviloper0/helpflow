{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module API.API (API) where

import Servant
import Application.Identity.RegisterRequest
import Application.Identity.LoginRequest

import API.RegisterResponse
type API =
       "register" -- POST /register
           :> ReqBody '[JSON] RegisterRequest
           :> Post '[JSON] RegisterResponse

  :<|> "login" -- POST /login
           :> ReqBody '[JSON] LoginRequest
           :> Post '[JSON] NoContent -- vou deixar generico por enquanto