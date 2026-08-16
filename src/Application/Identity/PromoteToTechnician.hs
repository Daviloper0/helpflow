{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Application.Identity.PromoteToTechnician
    ( promoteToTechnician
    , PromoteError(..)
    ) where

import Domain.Identity.User
import Infrastructure.Identity.UserRepository

data PromoteError =
    NotAdministrator
    | UserNotFound
    | AlreadyTechnician
    deriving (Eq, Show)

-- a ideia é só permitir administradores fazerem a promoção
promoteToTechnician :: User -> User -> IO (Either PromoteError User)
promoteToTechnician administrator targetUser =
    case userRole administrator of
        Administrator ->
            case userRole targetUser of
                Technician -> pure (Left AlreadyTechnician)

                _ -> do
                    updated <- updateUserRole targetUser Technician

                    if updated
                    then
                        pure (Right targetUser { userRole = Technician })
                    else
                        pure (Left UserNotFound)
        _ ->
            pure (Left NotAdministrator)