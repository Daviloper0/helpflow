{-# LANGUAGE DataKinds #-}

module Application.Identity.Login (login, LoginError(..)) where

import Application.Identity.LoginRequest
import Domain.Identity.User
import Domain.Identity.Email
import Domain.Identity.Password
import Domain.Identity.PasswordHash


data LoginError = 
    InvalidLoginEmail EmailError
    | InvalidLoginPassword PasswordError
    | InvalidCredentials
    deriving (Eq, Show)

login :: LoginRequest -> User -> IO (Either LoginError User)
login loginRequest user = do
    let emailResult = validateEmail (makeNonValidatedEmail (loginEmail loginRequest))
    let passwordResult = validatePassword (makeNonValidatedPassword (loginPassword loginRequest))
    {-A ideia é pegar um email-}
    
    {-Tão gambiarra quanto o RegisterUser-}

    case emailResult of
        Left emailError ->
            pure (Left (InvalidLoginEmail emailError))

        Right email ->
            case passwordResult of
                Left passwordError ->
                    pure (Left (InvalidLoginPassword passwordError))

                Right password -> do
                    let passwordIsCorrect = verifyPassword password (userPasswordHash user)

                    if email == userEmail user && passwordIsCorrect
                        then pure (Right user)
                        else pure (Left InvalidCredentials)