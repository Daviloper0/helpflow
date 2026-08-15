{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module API.ErrorResponse (ErrorResponse(..), errorResponse) where

import Servant
import Data.Aeson
import Data.Text (Text)
import qualified Data.Text as Text
import GHC.Generics (Generic)

-- Assim como o RegisterResponse, a ideia é criar um wrapper que vai conter todos os erros

data ErrorResponse = ErrorResponse
    { 
        errorCode :: Text, 
        errorMessage :: Text
    }
    deriving (Eq, Show, Generic)
instance ToJSON ErrorResponse

-- decidi mover para cá por que tanto register quanto login precisam desse errorresponse
errorResponse :: ServerError -> Text.Text -> Text.Text -> ServerError
errorResponse status code message =
    status
        { 
            errHeaders = [("Content-Type", "application/json")],
            errBody = encode (ErrorResponse code message)
        }
