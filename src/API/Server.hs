{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module API.Server (server) where

import Servant

import API.API
import API.Register
import API.Login
import Application.Identity.LoginRequest

server :: Server API
server =
    registerHandler
    :<|> loginHandler