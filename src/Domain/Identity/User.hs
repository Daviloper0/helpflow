{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}

module Domain.Identity.User (Role(..), User(..), roleText) where

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