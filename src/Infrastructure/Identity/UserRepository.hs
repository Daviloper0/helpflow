{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
module Infrastructure.Identity.UserRepository
    ( saveUser, findUserByEmail
    ) where

import Database.Persist
import Database.Persist.Sqlite
import Data.Text (Text)
import qualified Data.Text as Text
import Infrastructure.Database

import Domain.Identity.SharedStates
import Domain.Identity.User
import Domain.Identity.Email
import Domain.Identity.Name
import Domain.Identity.PasswordHash
import Domain.Identity.UserId 

saveUser :: User -> IO ()
saveUser user =
    runSqlite "helpflow.db" $ do
        insert_ (UserEntity
            (userIdToText(userId user))
            (emailText (userEmail user))
            (passwordHashText (userPasswordHash user))
            (nameText (userName user))
            (roleText (userRole user))
            )
-- novamente, não sei se existe algum jeito melhor de fazer isso, mas que dói os olhos, dói
findUserByEmail :: Text -> IO (Maybe User)
findUserByEmail email = do
    result <- findUserEntityByEmail email

    case result of
        Nothing ->
            pure Nothing

        Just (Entity _ userEntity) ->
            case makeUserId (userEntityUserId userEntity) of
                Nothing -> pure Nothing

                Just idOfUser ->
                    case parseEmail (userEntityEmail userEntity) of
                        Nothing -> pure Nothing

                        Just userEmail ->
                            case parseName (userEntityName userEntity) of
                                Nothing -> pure Nothing

                                Just userName ->
                                    case parseRole (userEntityRole userEntity) of
                                        Nothing -> pure Nothing

                                        Just userRole ->
                                            let userPasswordHash =
                                                    makePasswordHash
                                                        (userEntityPasswordHash userEntity)

                                                user = User
                                                    { userId = idOfUser
                                                    , userEmail = userEmail
                                                    , userPasswordHash = userPasswordHash
                                                    , userName = userName
                                                    , userRole = userRole
                                                    }

                                            in pure (Just user)