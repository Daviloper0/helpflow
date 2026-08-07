module Application.Identity.RegisterRequest (RegisterRequest(..)) where

import Data.Text

data RegisterRequest = RegisterRequest {
    registerName :: Text,
    registerEmail :: Text,
    registerPassword :: Text
    }
    deriving (Eq)

{-A ideia é receber as informações para serem validadas, por isso o text-}
