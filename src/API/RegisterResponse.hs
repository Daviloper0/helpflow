{-# LANGUAGE DeriveGeneric #-} 

module API.RegisterResponse (RegisterResponse(..)) where

import Data.Aeson
import Data.Text (Text)
import GHC.Generics (Generic)

-- a ideia de criar só um wrapper da resposta, para que o tipo seja sempre o mesmo
data RegisterResponse = RegisterResponse
    {
        responseMessage :: Text,
        responseUserId  :: Text
    }
    deriving (Eq, Show, Generic)

instance ToJSON RegisterResponse -- instancia de json, assim como no RegisterRequest e LoginRequest