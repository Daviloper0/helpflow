{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE OverloadedStrings #-}
module Domain.Identity.User (Role(..), User(..), roleText, parseRole, TechnicianId(..), makeTechnicianId, technicianIdToUserId) where

import Data.Text (Text)
import qualified Data.Text as Text

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

newtype TechnicianId = TechnicianId UserId
    deriving (Eq, Ord, Show)

{- Vamos utilizar smart constructor, para que apenas um user com cargo de técnico possa ter um TechnicianId-}
makeTechnicianId :: User -> Maybe TechnicianId
makeTechnicianId user =
    case userRole user of
        Technician -> Just (TechnicianId (userId user))
        _ -> Nothing

technicianIdToUserId :: TechnicianId -> UserId
technicianIdToUserId (TechnicianId technicianId) =
    technicianId

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

