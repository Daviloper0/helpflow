{-# LANGUAGE OverloadedStrings #-}

module API.Register (registerHandler) where

import Servant
import Control.Monad.IO.Class (liftIO) -- precisa disso porque o servant trabalha com Handler, mas registerUser retorna um IO, então esse liftIO pega a operação de IO e joga dentro do handler

import Data.Aeson (encode)
import qualified Data.Text as Text

import Application.Identity.RegisterRequest
import Application.Identity.RegisterUser
import API.RegisterResponse
import API.ErrorResponse


registerHandler :: RegisterRequest -> Handler RegisterResponse
registerHandler request = do
    result <- liftIO (registerUser request) -- quando chegamos aqui, sabemos que o request é um registro, então é possível fazer isso

    case result of
        Right _ -> pure (RegisterResponse (Text.pack "Usuário registrado com sucesso"))

        Left err -> throwError (registerErrorToServerError err)

--esse server erro tem duas partes, o generico, que é o que está em "" aqui, e o específico, que aí chama emailError, nameError, etc
registerErrorToServerError :: RegisterError -> ServerError
registerErrorToServerError registerError =
    case registerError of
        InvalidEmail emailError ->
            errorResponse err400 "invalid_email" (Text.pack (show emailError))

        InvalidName nameError ->
            errorResponse err400 "invalid_name" (Text.pack (show nameError))

        InvalidPassword passwordError ->
            errorResponse err400 "invalid_password" (Text.pack (show passwordError))

        EmailAlreadyExists ->
            errorResponse err409 "email_already_exists" "Email já cadastrado"

-- aqui a gente constroi a mensagem de erro, baseado na documentação do servant
errorResponse :: ServerError -> Text.Text -> Text.Text -> ServerError
errorResponse status code message =
    status
        { 
            errHeaders = [("Content-Type", "application/json")],
            errBody = encode (ErrorResponse code message)
        }