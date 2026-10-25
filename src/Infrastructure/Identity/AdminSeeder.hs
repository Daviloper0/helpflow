{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Infrastructure.Identity.AdminSeeder (seedAdminIfNeeded) where

import Data.Text (Text)

import Domain.Identity.User
import Domain.Identity.Email
import Domain.Identity.Name
import Domain.Identity.Password
import Domain.Identity.PasswordHash
import Domain.Identity.UserId

import Infrastructure.Identity.UserRepository

defaultAdminEmail :: Text
defaultAdminEmail = "admin@helpflow.com"

seedAdminIfNeeded :: IO ()
seedAdminIfNeeded = do
    existing <- findUserByEmail defaultAdminEmail
    case existing of
        Just _ -> pure ()
        Nothing -> do
            email    <- either (error "seed: invalid admin email")    pure (validateEmail    (makeNonValidatedEmail    defaultAdminEmail))
            name     <- either (error "seed: invalid admin name")     pure (validateName     (makeNonValidatedName     "Admin"))
            password <- either (error "seed: invalid admin password") pure (validatePassword (makeNonValidatedPassword "Admin@123"))
            passwordHash <- hashPassword password
            adminId      <- generateUserId
            let admin = User
                    { userId           = adminId
                    , userEmail        = email
                    , userPasswordHash = passwordHash
                    , userName         = name
                    , userRole         = Administrator
                    }
            saveUser admin
            putStrLn "Admin padrão criado: admin@helpflow.com / Admin@123"
