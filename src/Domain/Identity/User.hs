{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE OverloadedStrings #-}
module Domain.Identity.User (Role(..), User(..), roleText, parseRole) where

import Domain.Identity.UserId (UserId)
import Domain.Identity.Email (Email)
import Domain.Identity.PasswordHash (PasswordHash)
import Domain.Identity.Name (Name)
import Domain.Identity.SharedStates
import Data.Text (Text)
import qualified Data.Text as Text

data Role =
    Customer
    | Technician
    | Administrator
    deriving (Eq, Show)
{-Para o role, usamos um ADT, assim é possível garantir que userRole só possa ter 3 opções-}

data User = User {
    userId :: UserId,
    userEmail :: Email 'Validated,
    userPasswordHash :: PasswordHash,
    userName :: Name 'Validated,
    userRole :: Role
    }
    deriving (Eq, Show) 
    
roleText :: Role -> Text
roleText Customer = Text.pack("Customer")
roleText Technician = Text.pack("Technician")
roleText Administrator = Text.pack("Administrator")

-- para poder receber texto do banco de dados e talvez transformar em Role
parseRole :: Text -> Maybe Role
parseRole text =
    case text of
        "Customer" -> Just Customer
        "Technician" -> Just Technician
        "Administrator" -> Just Administrator
        _ -> Nothing