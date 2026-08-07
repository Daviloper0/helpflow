module Application.Identity.LoginRequest (LoginRequest(..)) where

import Data.Text (Text)

data LoginRequest = LoginRequest {
    loginEmail :: Text,
    loginPassword :: Text
    }
    deriving (Eq)
-- assim como no RegsiterRequest, é um text porque ainda precisa ser verificado