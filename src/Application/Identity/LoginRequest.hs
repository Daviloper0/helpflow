{-# LANGUAGE DeriveGeneric #-} 

module Application.Identity.LoginRequest (LoginRequest(..)) where

import Data.Text (Text)
import GHC.Generics (Generic)
import Data.Aeson

data LoginRequest = LoginRequest {
    loginEmail :: Text,
    loginPassword :: Text
    }
    deriving (Eq, Show, Generic)

instance FromJSON LoginRequest

-- assim como no RegsiterRequest, é um text porque ainda precisa ser verificado