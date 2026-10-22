{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module API.PromoteToTechnician (promoteToTechnicianHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import API.RegisterResponse
import API.ErrorResponse

import Application.Identity.PromoteToTechnician

import Domain.Identity.User
import Domain.Identity.UserId

import Infrastructure.Identity.UserRepository

import Data.Text (Text)

promoteToTechnicianHandler :: Text -> Text -> Handler RegisterResponse
promoteToTechnicianHandler administratorIdText targetUserIdText = do
    administratorId <- case makeUserId administratorIdText of
        Nothing -> throwError (errorResponse err400 "INVALID_USER_ID" "Invalid administratorId")
        Just uid -> pure uid

    targetUserId <- case makeUserId targetUserIdText of
        Nothing -> throwError (errorResponse err400 "INVALID_USER_ID" "Invalid targetUserId")
        Just uid -> pure uid

    administrator <- liftIO (findUserById administratorId)

    case administrator of
        Nothing ->
            throwError (errorResponse err404 "USER_NOT_FOUND" "Administrator not found")

        Just admin -> do
            targetUser <- liftIO (findUserById targetUserId)

            case targetUser of
                Nothing -> throwError (errorResponse err404 "USER_NOT_FOUND" "User not found")

                Just user -> do
                    result <- liftIO (promoteToTechnician admin user)

                    case result of
                        Left NotAdministrator -> throwError (errorResponse err403 "NOT_ADMINISTRATOR" "Only administrators can promote users to technician")

                        Left AlreadyTechnician -> throwError(errorResponse err409 "ALREADY_TECHNICIAN" "User is already a technician")

                        Left UserNotFound -> throwError (errorResponse err404 "USER_NOT_FOUND" "User not found")

                        Right user -> pure (RegisterResponse "User is now a technician" (userIdToText (userId user)))