{-#LANGUAGE OverloadedStrings #-}

module Tests.RegisterUserSpec (setupTestUser, registerUserTests) where

import Test.Tasty
import Test.Tasty.HUnit
import qualified Data.Text as Text

import Application.Identity.RegisterRequest
import Application.Identity.RegisterUser

import Domain.Identity.User
import Domain.Identity.Email
import Domain.Identity.Password
import Domain.Identity.Name

import Infrastructure.Identity.UserRepository

testRequest :: RegisterRequest
testRequest =
    RegisterRequest
        { 
            registerName = "Usuario Teste",
            registerEmail = "emailbomba@email.com",
            registerPassword = "OutraSenha123@!"
        }

setupTestUser :: IO ()
setupTestUser = do
    existingUser <- findUserByEmail "emailbomba@email.com"

    case existingUser of
        Just _ ->
            pure ()

        Nothing -> do
            result <- registerUser testRequest

            case result of
                Left err ->
                    error ("Falha ao criar usuário de teste: " ++ show err)

                Right _ ->
                    pure ()
                    
registerUserTests :: TestTree
registerUserTests = testGroup "Testes de registro"
    [
    
    testCase "Email já cadastrado" (do
        result <- registerUser (RegisterRequest
            (Text.pack "OutroUsuario")
            (Text.pack "emailbomba@email.com")
            (Text.pack "OutraSenha123@!"))

        result @?= Left EmailAlreadyExists
    ),

{- ->>--------------------------------TESTES DOS EMAILS--------------------------------<<- -}
    testCase "Email vazio" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack(""))
                (Text.pack("SenhaSuperSegura123@")))

            result @?= Left (InvalidEmail EmptyEmail)
    ),
    testCase "Email começa com @" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("@arrobanocomeco@gmail.com"))
                (Text.pack("SenhaSuperSegura123@")))

            result @?= Left (InvalidEmail StartsWithAt)
    ),

    testCase "Email começa com ." (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack(".haskelltemsintaxeestranhja@haskell.org"))
                (Text.pack("SenhaSuperSegura123@")))

            result @?= Left (InvalidEmail StartsWithDot)
    ),

    testCase "Email com mais de um @" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("naoqueromaisprogramar@@gmail.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            result @?= Left (InvalidEmail TooManyAts)
    ),


    testCase "Email termina com @" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("porquequeeufuiinventardefazerisso@gmail.com@"))
                (Text.pack("SenhaSuperSegura123@!")))

            result @?= Left (InvalidEmail EndsWithAt)
    ),

    testCase "Email termina com ." (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("desenvolvimentoguiadoatipos@ufabc.edu.br."))
                (Text.pack("SenhaSuperSegura123@!")))

            result @?= Left (InvalidEmail EndsWithDot)
    ),

    {- ->>--------------------------------TESTES DOS NOMES--------------------------------<<- -}
    testCase "Nome vazio" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack(""))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            result @?= Left (InvalidName EmptyName)
    ),

    testCase "Nome com número" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("Haskell da Silva G0mes"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            result @?= Left (InvalidName InvalidCharacter)
    ),

    testCase "Nome com símbolo" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("Desenvolvimento Guiado a Tipos$"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            result @?= Left (InvalidName InvalidCharacter)
    ),

    testCase "Nome muito longo" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("Adolph Blaine Charles David Earl Frederick Gerald Hubert Irvin John Kenneth Lloyd Martin Nero Oliver Paul Quincy Randolph Sherman Thomas Uncas Victor William Xerxes Yancy Zeus "))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            result @?= Left (InvalidName NameTooLong)
    ),

    testCase "Nome muito curto" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("hs"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            result @?= Left (InvalidName NameTooShort)
    ),
     testCase "Senha Vazia" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("")))

            result @?= Left (InvalidPassword EmptyPassword)
    ),

    testCase "Senha muito curta" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("S$m39@")))

            result @?= Left (InvalidPassword PasswordTooShort)
    ),

    testCase "Senha muito longa" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("H632qnf6IH1tR8mjIM6QYJ4738dK20X800B4Yor3Lc54X4pI6QsIo6E2pv1gy8771")))

            result @?= Left (InvalidPassword PasswordTooLong)
    ),

    testCase "Senha tem espaços" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("s e n h a")))

            result @?= Left (InvalidPassword PasswordHasSpaces)
    ),

    testCase "Senha não tem letras maiúsculas" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("haskelldificil")))

            result @?= Left (InvalidPassword PasswordHasNoUpperCase)
    ),

    testCase "Senha não tem letras minúsculas" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SENHAESTRANHA")))

            result @?= Left (InvalidPassword PasswordHasNoLowerCase)
    ),

    testCase "Senha não tem caracteres especiais" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("As3SenhasAnterioresCairiamNisso")))

            result @?= Left (InvalidPassword PasswordHasNoSpecialCharacters)
    ),

    testCase "Senha não tem números" (
        do
            result <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("S$nhaSemNumeros")))

            result @?= Left (InvalidPassword PasswordHasNoNumber)
    )
    ]