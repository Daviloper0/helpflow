{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module API.Server (server) where

import Servant

import API.API
import API.Register
import Application.Identity.LoginRequest

server :: Server API
server =
    registerHandler
    :<|> loginHandler

-- só um handler generico porque ainda nao fiz
loginHandler :: LoginRequest -> Handler NoContent
loginHandler _ =
    throwError err501