{-# LANGUAGE OverloadedStrings #-} -- facilita no runSqlite
--tudo boilerplate do persistent
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}

{-# LANGUAGE TypeOperators #-} -- reclamou se não usasse
-- usando como base https://hackage-content.haskell.org/package/persistent-2.18.1.0/docs/Database-Persist.html + reclamações do compilador

module Infrastructure.Database (UserEntity(..), UserEntityId, TicketEntity(..), TicketEntityId, findUserEntityByEmail, findUserEntityById, migrateDatabase, migrateAll) where

import Data.Text (Text)
import Data.List (find)

import Database.Persist
import Database.Persist.Sqlite
import Database.Persist.TH

-- UserEntity usa text em todos os campos porque não tinha muito para o que mapear além disso
share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
UserEntity
    userId Text
    email Text
    passwordHash Text
    name Text
    role Text
    deriving Show

TicketEntity
    title Text
    description Text
    status Text
    priority Text
    category Text
    createdBy Text
    assignedTo Text Maybe
    deriving Show
|]
-- tentei separar isso colocando essa parte no UserRepository, mas me encheu de problemas, então desisti
findUserEntityByEmail :: Text -> IO (Maybe (Entity UserEntity))
findUserEntityByEmail email =
    runSqlite "helpflow.db" $
        selectFirst [UserEntityEmail ==. email] []

-- Tentei usar o persistent para procurar, mas tive muito problema, então decidi fazer desse jeito
findUserEntityById :: Text -> IO (Maybe (Entity UserEntity))
findUserEntityById userId =
    runSqlite "helpflow.db" $ do
        entities <- selectList [] []

        pure (findUserById userId entities)

findUserById :: Text -> [Entity UserEntity] -> Maybe (Entity UserEntity)
findUserById userId entities =
    find (\(Entity _ userEntity) -> userEntityUserId userEntity == userId) entities

migrateDatabase :: IO ()
migrateDatabase =
    runSqlite "helpflow.db" $ do
        runMigration migrateAll