{-# LANGUAGE DataKinds #-}

module Main (main) where

import Network.Wai.Handler.Warp
import Servant

import API.API
import API.Server
import Infrastructure.Database (migrateDatabase)
import Infrastructure.Identity.AdminSeeder (seedAdminIfNeeded)

main :: IO ()
main = do
    migrateDatabase
    seedAdminIfNeeded
    putStrLn "Servidor rodando em http://localhost:4284"
    run 4284 (serve (Proxy :: Proxy API) server)