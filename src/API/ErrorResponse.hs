{-# LANGUAGE DeriveGeneric #-}

module API.ErrorResponse (ErrorResponse(..)) where

import Data.Aeson
import Data.Text (Text)
import GHC.Generics (Generic)

-- Assim como o RegisterResponse, a ideia é criar um wrapper que vai conter todos os erros

data ErrorResponse = ErrorResponse
    { errorCode :: Text
    , errorMessage :: Text
    }
    deriving (Eq, Show, Generic)

instance ToJSON ErrorResponse