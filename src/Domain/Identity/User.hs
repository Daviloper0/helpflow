module Domain.Identity.User (Role, User(..)) where

import Data.Text (Text)

data Role =
    Customer
    | Technician
    | Administrator
    deriving (Eq)
{-Para o role, usamos um ADT, assim é possível garantir que userRole só possa ter 3 opções-}

data User = User {
    userId :: Int,
    userEmail :: Text,
    userPasswordHash :: Text,
    userName :: Text,
    userRole :: Role
    }
    deriving (Eq) 
