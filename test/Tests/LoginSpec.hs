module Tests.LoginSpec (loginTests) where

import Test.Tasty
import Test.Tasty.HUnit
import qualified Data.Text as Text

import Application.Identity.LoginRequest
import Application.Identity.Login

import Domain.Identity.User
import Domain.Identity.Email
import Domain.Identity.Password

--Pode ser meio repetitivo retestar os casos de email, name e password, mas acho bom ter certeza kkkkk
-- como mudança da última versão, tive que tirar a criação de um registro para comparação (porque agora criar um registro realmente cria no banco de dados), então tive que tirar tudo que criava
loginTests :: TestTree
loginTests = testGroup "Testes de login"
    [
    testCase "Login válido" (do
        result <- login (LoginRequest
            (Text.pack "emailbomba@email.com")
            (Text.pack "OutraSenha123@!"))

        case result of
            Right loggedUser ->
                userRole loggedUser @?= Customer

            Left err ->
                assertFailure ("Login deveria ser valido: " ++ show err)
    ),

    {- ->>--------------------------------TESTES DOS EMAILS--------------------------------<<- -}

    testCase "Email vazio" (do
        result <- login (LoginRequest
            (Text.pack "")
            (Text.pack "SenhaSuperSegura123@!"))

        result @?= Left (InvalidLoginEmail EmptyEmail)
    ),

    testCase "Email começa com @" (do
        result <- login (LoginRequest
            (Text.pack "@emailbomba.com")
            (Text.pack "SenhaSuperSegura123@!"))

        result @?= Left (InvalidLoginEmail StartsWithAt)
    ),

    testCase "Email começa com ." (do
        result <- login (LoginRequest
            (Text.pack ".emailbomba@email.com")
            (Text.pack "SenhaSuperSegura123@!"))

        result @?= Left (InvalidLoginEmail StartsWithDot)
    ),

    testCase "Email com mais de um @" (do
        result <- login (LoginRequest
            (Text.pack "email@@bomba@email.com")
            (Text.pack "SenhaSuperSegura123@!"))

        result @?= Left (InvalidLoginEmail TooManyAts)
    ),

    testCase "Email termina com @" (do
        result <- login (LoginRequest
            (Text.pack "emailbomba@email.com@")
            (Text.pack "SenhaSuperSegura123@!"))

        result @?= Left (InvalidLoginEmail EndsWithAt)
    ),

    testCase "Email termina com ." (do
        result <- login (LoginRequest
            (Text.pack "emailbomba@email.com.")
            (Text.pack "SenhaSuperSegura123@!"))

        result @?= Left (InvalidLoginEmail EndsWithDot)
    ),

    {- ->>--------------------------------TESTES DAS SENHAS--------------------------------<<- -}

    testCase "Senha vazia" (do
        result <- login (LoginRequest
            (Text.pack "emailbomba@email.com")
            (Text.pack ""))

        result @?= Left (InvalidLoginPassword EmptyPassword)
    ),

    {- ->>--------------------------------TESTES DAS CREDENCIAIS--------------------------------<<- -}

    testCase "Senha incorreta" (do
        result <- login (LoginRequest
            (Text.pack "emailbomba@email.com")
            (Text.pack "SenhaErrada123@!"))

        result @?= Left InvalidCredentials
    ),

    testCase "Email incorreto" (do
        result <- login (LoginRequest
            (Text.pack "outro@email.com")
            (Text.pack "SenhaSuperSegura123@!"))

        result @?= Left InvalidCredentials
    )
    ]