{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}

module Domain.Identity.Email (Email, EmailError(..), makeNonValidatedEmail, validateEmail) where

import Data.Text (Text)
import qualified Data.Text as Text
import Domain.Identity.SharedStates

data EmailError = 
    EmptyEmail
    | TooManyAts
    | StartsWithAt
    | EndsWithAt
    | StartsWithDot
    | EndsWithDot
    deriving (Eq, Show)
    
{-Aqui criamos um tipo fantasma de email, onde cada email tem um estado, não-validado e validado
e o compilador ajuda a garantir que o fluxo será correto-}

newtype Email (state :: ValidationState) = MakeEmail Text
    deriving (Eq, Show)

makeNonValidatedEmail :: Text -> Email 'NonValidated
makeNonValidatedEmail recievedText = MakeEmail recievedText

validateEmail :: Email 'NonValidated -> Either EmailError (Email 'Validated)
validateEmail (MakeEmail email)
    | Text.null email = Left EmptyEmail
    | Text.head email == '@' = Left StartsWithAt
    | Text.head email == '.' = Left StartsWithDot
    | Text.last email == '@' = Left EndsWithAt
    | Text.last email == '.' = Left EndsWithDot
    | Text.count (Text.pack "@") email > 1 = Left TooManyAts -- quero que esse seja o caso mais geral, os outros são mais específicos
    | otherwise = Right (MakeEmail email)
    