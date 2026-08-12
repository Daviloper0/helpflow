{-# LANGUAGE DataKinds #-}

module Application.Identity.Login (login, LoginError(..)) where

import Application.Identity.LoginRequest
import Infrastructure.Identity.UserRepository
import Domain.Identity.User
import Domain.Identity.Email
import Domain.Identity.Password
import Domain.Identity.PasswordHash

data LoginError =
    InvalidLoginEmail EmailError
    | InvalidLoginPassword PasswordError
    | InvalidCredentials
    deriving (Eq, Show)

login :: LoginRequest -> IO (Either LoginError User)
login loginRequest = do
    let emailResult =
            validateEmail
                (makeNonValidatedEmail (loginEmail loginRequest))

    let passwordResult =
            validatePassword
                (makeNonValidatedPassword (loginPassword loginRequest))

    case emailResult of
        Left emailError ->
            pure (Left (InvalidLoginEmail emailError))

        Right email ->
            case passwordResult of
                Left passwordError ->
                    pure (Left (InvalidLoginPassword passwordError))

                Right password -> do
                    {- agora finalmente implementando a função de verificar no banco de dados, ideia meio óbvia, 
                    mas vê se o email existe no db. Ainda pensando se vou separar as credenciais invalidas para emailNotFound e incorrectPassword
                    não sei se é uma boa prática-}

                    userResult <- findUserByEmail (emailText email)

                    case userResult of
                        Nothing ->
                            pure (Left InvalidCredentials)

                        Just user ->
                            let passwordIsCorrect =
                                    verifyPassword
                                        password
                                        (userPasswordHash user)
                            in
                                if passwordIsCorrect
                                    then pure (Right user)
                                    else pure (Left InvalidCredentials)