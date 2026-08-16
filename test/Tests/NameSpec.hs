module Tests.NameSpec (nameTests) where

import Test.Tasty
import Test.Tasty.HUnit
import qualified Data.Text as Text

import Domain.Identity.Name

nameTests :: TestTree
nameTests = testGroup "Testes de Nome"
    [
    testCase "Nome vazio" (
        validateName (makeNonValidatedName (Text.pack("")))
        @?= Left EmptyName
    ),
    testCase "Nome com número" (
        validateName (makeNonValidatedName (Text.pack("Haskell da Silva G0mes")))
        @?= Left InvalidCharacter
    ),
    testCase "Nome com Símbolo" (
        validateName (makeNonValidatedName (Text.pack("Desenvolvimento Guiado a Tipos$")))
        @?= Left InvalidCharacter
    ),
    testCase "Nome muito Longo" (
        validateName(makeNonValidatedName (Text.pack("Adolph Blaine Charles David Earl Frederick Gerald Hubert Irvin John Kenneth Lloyd Martin Nero Oliver Paul Quincy Randolph Sherman Thomas Uncas Victor William Xerxes Yancy Zeus ")))
        @?= Left NameTooLong
    ),
    testCase "Nome muito curto" (
        validateName (makeNonValidatedName (Text.pack("hs")))
        @?= Left NameTooShort
    )
    ]