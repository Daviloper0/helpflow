{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
module Domain.Identity.Name (NameError(..), makeNonValidatedName, validateName, Name)where

import Data.Char(isLetter, isSpace)
import Data.Text (Text)
import qualified Data.Text as Text
import Domain.Identity.SharedStates

data NameError = 
    EmptyName
    | NameTooShort
    | NameTooLong
    | InvalidCharacter
    deriving (Eq, Show)

makeNonValidatedName :: Text -> Name 'NonValidated
makeNonValidatedName recievedText = MakeName recievedText

normalizeName :: Text -> Text
normalizeName name =
    Text.unwords (Text.words (name))

isValidCharacter :: Char -> Bool
isValidCharacter character =
    isLetter character || isSpace character || character == '-'
newtype Name (state :: ValidationState) = MakeName Text
    deriving (Eq, Show)

validateName :: Name 'NonValidated -> Either NameError (Name 'Validated)
validateName (MakeName name)
    | Text.null (normalizeName name) = Left EmptyName
    | Text.length (normalizeName name) < 3 = Left NameTooShort --suponho que não existam nomes com menos de três letras
    | Text.length (normalizeName name) > 100 = Left NameTooLong--infelizmente Laurence Watkins não vai poder usar o helpflow se quiser colocar o nome inteiro
    | not (Text.all isValidCharacter(normalizeName name)) = Left InvalidCharacter
    | otherwise = Right (MakeName (normalizeName name))