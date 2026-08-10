module Main (main) where

import Test.Tasty

import Tests.EmailSpec
import Tests.NameSpec
import Tests.PasswordSpec
import Tests.RegisterUserSpec
import Tests.LoginSpec
tests :: TestTree
tests = testGroup "HelpFlow Tests"
        [emailTests, nameTests, passwordTests, registerUserTests, loginTests]

main :: IO ()
main =
    defaultMain tests
