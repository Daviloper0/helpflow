{-# LANGUAGE DeriveGeneric #-} 
module Application.Identity.RegisterRequest (RegisterRequest(..)) where

import Data.Text
import Data.Aeson
import GHC.Generics (Generic)


data RegisterRequest = RegisterRequest {
    registerName :: Text,
    registerEmail :: Text,
    registerPassword :: Text
    }
    deriving (Eq, Generic) -- generic ajuda a assumir que o json corresponde a essa estrutura de dados

instance FromJSON RegisterRequest -- é necessário definir a instância de FromJSON   
{-A ideia é receber as informações para serem validadas, por isso o text-}