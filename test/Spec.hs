module Main (main) where

import Test.Tasty

import Tests.EmailSpec
import Tests.NameSpec
import Tests.PasswordSpec
import Tests.RegisterUserSpec

tests :: TestTree
tests = testGroup "HelpFlow Tests"
        [emailTests, nameTests, passwordTests, registerUserTests]

main :: IO ()
main =
    defaultMain tests
