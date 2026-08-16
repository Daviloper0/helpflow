{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module API.PromoteToTechnician (promoteToTechnicianHandler) where

import Servant
import Control.Monad.IO.Class (liftIO)

import Application.Identity.PromoteToTechnician
import API.RegisterResponse
import API.ErrorResponse

import Domain.Identity.UserId
import Domain.Identity.User
import Infrastructure.Identity.UserRepository

promoteToTechnicianHandler :: UserId -> UserId -> Handler RegisterResponse
promoteToTechnicianHandler administratorId targetUserId = do
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

                        Right _ -> pure (RegisterResponse "User is now a technician")