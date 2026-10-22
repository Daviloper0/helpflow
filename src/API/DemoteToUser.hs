{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module API.DemoteToUser (demoteToUserHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import API.RegisterResponse
import API.ErrorResponse

import Application.Identity.DemoteToUser

import Domain.Identity.User
import Domain.Identity.UserId

import Infrastructure.Identity.UserRepository

demoteToUserHandler :: UserId -> UserId -> Handler RegisterResponse
demoteToUserHandler administratorId targetUserId = do
    administrator <- liftIO (findUserById administratorId)

    case administrator of
        Nothing ->
            throwError (errorResponse err404 "USER_NOT_FOUND" "Administrator not found")

        Just admin -> do
            targetUser <- liftIO (findUserById targetUserId)

            case targetUser of
                Nothing -> throwError (errorResponse err404 "USER_NOT_FOUND" "User not found")

                Just user -> do
                    result <- liftIO (demoteToUser admin user)

                    case result of
                        Left NotAdministrator -> throwError (errorResponse err403 "NOT_ADMINISTRATOR" "Only administrators can demote users")

                        Left AlreadyUser -> throwError (errorResponse err409 "ALREADY_USER" "User is already a customer")

                        Left UserNotFound -> throwError (errorResponse err404 "USER_NOT_FOUND" "User not found")

                        Right user -> pure (RegisterResponse "User has been demoted to customer" (userIdToText (userId user)))
