{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}

module Domain.Identity.Password (PasswordError(..), makeNonValidatedPassword, validatePassword, Password, passwordText) where

import Data.Char (isLower, isUpper, isDigit, isSpace)
import Data.Text (Text)
import qualified Data.Text as Text

import Domain.Identity.SharedStates

data PasswordError = 
    EmptyPassword
    | PasswordTooShort
    | PasswordTooLong
    | PasswordHasSpaces
    | PasswordHasNoNumber
    | PasswordHasNoUpperCase
    | PasswordHasNoLowerCase
    | PasswordHasNoSpecialCharacters
    deriving (Eq, Show)

{-Assim como no email, usamos tipos fantasmas em Password, para que lugares como PasswordHash 
só aceitarem senhas que já passaram por validação -}

newtype Password (state :: ValidationState) = MakePassword Text
    deriving (Eq, Show)

isEmpty :: Text -> Bool
isEmpty password = Text.null password

isTooShort :: Text -> Bool
isTooShort password = Text.length password < 8

isTooLong :: Text -> Bool
isTooLong password = Text.length password > 64

hasSpace :: Text -> Bool
hasSpace password = Text.any isSpace password

hasNoUpperCase :: Text -> Bool
hasNoUpperCase password = not (Text.any isUpper password)

hasNoLowerCase :: Text -> Bool
hasNoLowerCase password = not (Text.any isLower password)

hasNoSpecialCharacters :: Text -> Bool
hasNoSpecialCharacters password = not (Text.any (\character -> not (isUpper character || isLower character || isDigit character || isSpace character)) password)

hasNoNumber :: Text -> Bool
hasNoNumber password = not(Text.any isDigit password)

makeNonValidatedPassword :: Text -> Password 'NonValidated
makeNonValidatedPassword recievedText = MakePassword recievedText

validatePassword :: Password 'NonValidated -> Either PasswordError (Password 'Validated)
validatePassword (MakePassword password)
    | isEmpty password = Left EmptyPassword
    | isTooShort password = Left PasswordTooShort
    | isTooLong password = Left PasswordTooLong
    | hasSpace password = Left PasswordHasSpaces
    | hasNoUpperCase password = Left PasswordHasNoUpperCase
    | hasNoLowerCase password = Left PasswordHasNoLowerCase
    | hasNoSpecialCharacters password = Left PasswordHasNoSpecialCharacters
    | hasNoNumber password = Left PasswordHasNoNumber
    | otherwise = Right (MakePassword password)

passwordText :: Password 'Validated -> Text
passwordText (MakePassword password) = password