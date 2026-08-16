{-#LANGUAGE OverloadedStrings #-}

module Main (main) where

import Test.Tasty
import Data.Text as Text
import qualified Data.Text as Text
import Tests.EmailSpec
import Tests.NameSpec
import Tests.PasswordSpec
import Tests.RegisterUserSpec
import Tests.LoginSpec

import Infrastructure.Database (migrateDatabase)
tests :: TestTree
tests = testGroup "HelpFlow Tests"
        [emailTests, nameTests, passwordTests, registerUserTests, loginTests]

main :: IO ()
main = do
        migrateDatabase
        setupTestUser
        defaultMain tests
