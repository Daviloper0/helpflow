module Tests.PasswordSpec (passwordTests) where

import Test.Tasty
import Test.Tasty.HUnit
import qualified Data.Text as Text
import Domain.Password  

passwordTests :: TestTree
passwordTests = testGroup "Testes de senha"
    [
    testCase "Senha Vazia" (
        validatePassword (makeNonValidatedPassword (Text.pack("")))
        @?= Left EmptyPassword
    ),
    testCase "Senha muito curta" (
        validatePassword (makeNonValidatedPassword (Text.pack("S$m39@")))
        @?= Left PasswordTooShort
    ),
    testCase "Senha muito longa" (
        validatePassword (makeNonValidatedPassword (Text.pack("H632qnf6IH1tR8mjIM6QYJ4738dK20X800B4Yor3Lc54X4pI6QsIo6E2pv1gy8771")))
        @?= Left PasswordTooLong
    ),
    testCase "Senha tem espaços" (
        validatePassword (makeNonValidatedPassword (Text.pack("s e n h a")))
        @?= Left PasswordHasSpaces
    ),
    testCase "Senha não tem letras maiúsculas" (
        validatePassword (makeNonValidatedPassword (Text.pack("haskelldificil")))
        @?= Left PasswordHasNoUpperCase
    ),
    testCase "Senha não tem letras minúsculas" (
        validatePassword (makeNonValidatedPassword (Text.pack("SENHAESTRANHA")))
        @?= Left PasswordHasNoLowerCase
    ),
    testCase "Senha não tem caracteres especiais" (
        validatePassword (makeNonValidatedPassword (Text.pack("As3SenhasAnterioresCairiamNisso")))
        @?= Left PasswordHasNoSpecialCharacters
    ),
    testCase "Senha não tem números" (
        validatePassword (makeNonValidatedPassword (Text.pack("S$nhaSemNumeros")))
        @?= Left PasswordHasNoNumber
    )
    ]