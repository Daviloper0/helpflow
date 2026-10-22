{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Application.Identity.DemoteToUser
    ( demoteToUser
    , DemoteError(..)
    ) where

import Domain.Identity.User

import Infrastructure.Identity.UserRepository

data DemoteError =
    NotAdministrator
    | UserNotFound
    | AlreadyUser
    deriving (Eq, Show)

demoteToUser :: User -> User -> IO (Either DemoteError User)
demoteToUser administrator targetUser =
    case userRole administrator of
        Administrator ->
            case userRole targetUser of
                Customer -> pure (Left AlreadyUser)

                _ -> do
                    updated <- updateUserRole targetUser Customer

                    if updated
                    then
                        pure (Right targetUser { userRole = Customer })
                    else
                        pure (Left UserNotFound)
        _ ->
            pure (Left NotAdministrator)
