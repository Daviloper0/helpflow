module Main (main) where

import Test.Tasty

import Tests.EmailSpec
import Tests.NameSpec

tests :: TestTree
tests = testGroup "HelpFlow Tests"
        [emailTests, nameTests]

main :: IO ()
main =
    defaultMain tests
