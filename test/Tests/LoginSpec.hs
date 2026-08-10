module Tests.LoginSpec (loginTests) where

import Test.Tasty
import Test.Tasty.HUnit
import qualified Data.Text as Text

import Application.Identity.LoginRequest
import Application.Identity.Login
import Application.Identity.RegisterRequest
import Application.Identity.RegisterUser
import Domain.Identity.User
import Domain.Identity.Email
import Domain.Identity.Password

--Pode ser meio repetitivo retestar os casos de email, name e password, mas acho bom ter certeza kkkkk
loginTests :: TestTree
loginTests = testGroup "Testes de login"
    [
    testCase "Login válido" (do
        registerResult <- registerUser (RegisterRequest
            (Text.pack("UsuarioBomba"))
            (Text.pack("emailbomba@email.com"))
            (Text.pack("SenhaSuperSegura123@!")))

        case registerResult of
            Right user -> do
                result <- login (LoginRequest
                    (Text.pack("emailbomba@email.com"))
                    (Text.pack("SenhaSuperSegura123@!")))
                    user

                case result of
                    Right loggedUser ->
                        userRole loggedUser @?= Customer

                    Left err ->
                        assertFailure ("Login deveria ser valido: " ++ show err)

            Left err ->
                assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    ),
    {- ->>--------------------------------TESTES DOS EMAILS--------------------------------<<- -}
    testCase "Email vazio" (
        do
            registerResult <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            case registerResult of
                Right user -> do
                    result <- login (LoginRequest
                        (Text.pack(""))
                        (Text.pack("SenhaSuperSegura123@!")))
                        user

                    result @?= Left (InvalidLoginEmail EmptyEmail)

                Left err ->
                    assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    ),

    testCase "Email começa com @" (
        do
            registerResult <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            case registerResult of
                Right user -> do
                    result <- login (LoginRequest
                        (Text.pack("@emailbomba.com"))
                        (Text.pack("SenhaSuperSegura123@!")))
                        user

                    result @?= Left (InvalidLoginEmail StartsWithAt)

                Left err ->
                    assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    ),

    testCase "Email começa com ." (
        do
            registerResult <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            case registerResult of
                Right user -> do
                    result <- login (LoginRequest
                        (Text.pack(".emailbomba@email.com"))
                        (Text.pack("SenhaSuperSegura123@!")))
                        user

                    result @?= Left (InvalidLoginEmail StartsWithDot)

                Left err ->
                    assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    ),

    testCase "Email com mais de um @" (
        do
            registerResult <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            case registerResult of
                Right user -> do
                    result <- login (LoginRequest
                        (Text.pack("email@@bomba@email.com"))
                        (Text.pack("SenhaSuperSegura123@!")))
                        user

                    result @?= Left (InvalidLoginEmail TooManyAts)

                Left err ->
                    assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    ),

    testCase "Email termina com @" (
        do
            registerResult <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            case registerResult of
                Right user -> do
                    result <- login (LoginRequest
                        (Text.pack("emailbomba@email.com@"))
                        (Text.pack("SenhaSuperSegura123@!")))
                        user

                    result @?= Left (InvalidLoginEmail EndsWithAt)

                Left err ->
                    assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    ),

    testCase "Email termina com ." (
        do
            registerResult <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            case registerResult of
                Right user -> do
                    result <- login (LoginRequest
                        (Text.pack("emailbomba@email.com."))
                        (Text.pack("SenhaSuperSegura123@!")))
                        user

                    result @?= Left (InvalidLoginEmail EndsWithDot)

                Left err ->
                    assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    ),

    {- ->>--------------------------------TESTES DAS SENHAS--------------------------------<<- -}

    testCase "Senha vazia" (
        do
            registerResult <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            case registerResult of
                Right user -> do
                    result <- login (LoginRequest
                        (Text.pack("emailbomba@email.com"))
                        (Text.pack("")))
                        user

                    result @?= Left (InvalidLoginPassword EmptyPassword)

                Left err ->
                    assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    ),

    {- ->>--------------------------------TESTES DAS CREDENCIAIS--------------------------------<<- -}

    testCase "Senha incorreta" (
        do
            registerResult <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            case registerResult of
                Right user -> do
                    result <- login (LoginRequest
                        (Text.pack("emailbomba@email.com"))
                        (Text.pack("SenhaErrada123@!")))
                        user

                    result @?= Left InvalidCredentials

                Left err ->
                    assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    ),

    testCase "Email incorreto" (
        do
            registerResult <- registerUser (RegisterRequest
                (Text.pack("UsuarioBomba"))
                (Text.pack("emailbomba@email.com"))
                (Text.pack("SenhaSuperSegura123@!")))

            case registerResult of
                Right user -> do
                    result <- login (LoginRequest
                        (Text.pack("outro@email.com"))
                        (Text.pack("SenhaSuperSegura123@!")))
                        user

                    result @?= Left InvalidCredentials

                Left err ->
                    assertFailure ("Não foi possível criar usuário para o teste: " ++ show err)
    )
    ]