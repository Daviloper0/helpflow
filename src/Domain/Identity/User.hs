{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}

module Domain.Identity.User (Role(..), User(..)) where

import Domain.Identity.UserId (UserId)
import Domain.Identity.Email (Email)
import Domain.Identity.PasswordHash (PasswordHash)
import Domain.Identity.Name (Name)
import Domain.Identity.SharedStates

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
