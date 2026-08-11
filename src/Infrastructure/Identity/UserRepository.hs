{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
module Infrastructure.Identity.UserRepository
    ( saveUser
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
