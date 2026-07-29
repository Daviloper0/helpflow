module Main (main) where

import Test.Tasty

import Tests.EmailSpec
import Tests.NameSpec
import Tests.PasswordSpec

tests :: TestTree
tests = testGroup "HelpFlow Tests"
        [emailTests, nameTests, passwordTests]

main :: IO ()
main =
    defaultMain tests
