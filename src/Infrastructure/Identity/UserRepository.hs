{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
module Infrastructure.Identity.UserRepository (saveUser, findUserByEmail, findUserById, updateUserRole) where

import Database.Persist
import Database.Persist.Sqlite
import Data.Text (Text)

import Domain.Identity.User
import Domain.Identity.Email
import Domain.Identity.Name
import Domain.Identity.PasswordHash
import Domain.Identity.UserId

import Infrastructure.Database

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
findUserByEmail givenEmail = do
    result <- findUserEntityByEmail givenEmail

    case result of
        Nothing ->
            pure Nothing

        Just (Entity _ userEntity) ->
            case makeUserId (userEntityUserId userEntity) of
                Nothing -> pure Nothing

                Just foundUserId ->
                    case parseEmail (userEntityEmail userEntity) of
                        Nothing -> pure Nothing

                        Just foundUserEmail ->
                            case parseName (userEntityName userEntity) of
                                Nothing -> pure Nothing

                                Just foundUserName ->
                                    case parseRole (userEntityRole userEntity) of
                                        Nothing -> pure Nothing

                                        Just foundUserRole ->
                                            let foundUserPasswordHash = makePasswordHash (userEntityPasswordHash userEntity)
                                                user = User
                                                    { 
                                                        userId = foundUserId, 
                                                        userEmail = foundUserEmail,
                                                        userPasswordHash = foundUserPasswordHash,
                                                        userName = foundUserName,
                                                        userRole = foundUserRole
                                                    }

                                            in pure (Just user)
-- alem de email, é util ter essa função de achar usuário por id, principalmente por causa dos técnicos
findUserById :: UserId -> IO (Maybe User)
findUserById givenUserId = do
    result <- findUserEntityById (userIdToText givenUserId)

    case result of
        Nothing ->
            pure Nothing

        Just (Entity _ userEntity) ->
            case makeUserId (userEntityUserId userEntity) of
                Nothing -> pure Nothing

                Just foundUserId ->
                    case parseEmail (userEntityEmail userEntity) of
                        Nothing -> pure Nothing

                        Just foundUserEmail ->
                            case parseName (userEntityName userEntity) of
                                Nothing -> pure Nothing

                                Just foundUserName ->
                                    case parseRole (userEntityRole userEntity) of
                                        Nothing -> pure Nothing

                                        Just foundUserRole ->
                                            let foundUserPasswordHash =
                                                    makePasswordHash
                                                        (userEntityPasswordHash userEntity)

                                                user = User
                                                    { 
                                                        userId = foundUserId, 
                                                        userEmail = foundUserEmail,
                                                        userPasswordHash = foundUserPasswordHash,
                                                        userName = foundUserName,
                                                        userRole = foundUserRole
                                                    }

                                            in pure (Just user)

-- criando essa função que dado um usuário e um role, atualiza o role do usuário para um específico
updateUserRole :: User -> Role -> IO Bool
updateUserRole user role = do
    result <- findUserEntityById (userIdToText (userId user))

    case result of
        Nothing ->
            pure False

        Just (Entity entityId userEntity) -> do
            runSqlite "helpflow.db" $ do
                replace entityId
                    userEntity
                        { 
                            userEntityRole = roleText role
                        }

            pure True