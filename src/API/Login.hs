{-# LANGUAGE OverloadedStrings #-}

module API.Login (loginHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import Data.Aeson (encode)
import qualified Data.Text as Text

import Application.Identity.LoginRequest
import Application.Identity.Login
import API.LoginResponse
import API.ErrorResponse
-- login é quase que uma cópia do register

loginHandler :: LoginRequest -> Handler LoginResponse
loginHandler request = do
    result <- liftIO (login request)

    case result of
        Right _ -> pure (LoginResponse (Text.pack "Login realizado com sucesso"))

        Left err -> throwError (loginErrorToServerError err)

loginErrorToServerError :: LoginError -> ServerError
loginErrorToServerError loginError =
    case loginError of
        InvalidLoginEmail emailError ->
            errorResponse err400 "invalid_email" (Text.pack (show emailError))

        InvalidLoginPassword passwordError ->
            errorResponse err400 "invalid_password" (Text.pack (show passwordError))

        InvalidCredentials ->
            errorResponse err401 "invalid_credentials""Email ou senha incorretos"
