{-# LANGUAGE DeriveGeneric #-}

module API.LoginResponse (LoginResponse(..)) where

import Data.Aeson
import Data.Text (Text)
import GHC.Generics (Generic)
-- exatamente a mesma coisa do RegisterResponse, só que para o login

data LoginResponse = LoginResponse
    { 
        loginMessage :: Text
        -- TODO: adicionar o token depois se der tempo
    }
    deriving (Eq, Show, Generic)

instance ToJSON LoginResponse