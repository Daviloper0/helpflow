{-# LANGUAGE DataKinds #-}

module Application.Identity.RegisterUser (registerUser, RegisterError(..)) where
import Application.Identity.RegisterRequest
import Domain.Identity.Name
import Domain.Identity.User 
import Domain.Identity.UserId 
import Domain.Identity.Email 
import Domain.Identity.Password 
import Domain.Identity.PasswordHash

import Infrastructure.Identity.UserRepository

data RegisterError = 
    InvalidEmail EmailError
    | InvalidName NameError
    | InvalidPassword PasswordError
    | EmailAlreadyExists
    deriving (Eq, Show)

registerUser :: RegisterRequest -> IO (Either RegisterError User)
registerUser registerRequest = do
    let nameResult = validateName (makeNonValidatedName (registerName registerRequest))
    let emailResult = validateEmail (makeNonValidatedEmail (registerEmail registerRequest))
    let passwordResult = validatePassword (makeNonValidatedPassword (registerPassword registerRequest))

    {-Meio gambiarra mas não sei outro jeito de fazer isso, vamos por cada um dos requests e verificamos se tem um erro
    assim a gente consegue passar o erro para outras partes do backend também-}
    case nameResult of
        Left nameError ->
            pure (Left (InvalidName nameError))
        
        Right name ->
            case emailResult of
                Left emailError ->
                    pure (Left (InvalidEmail emailError))
                
                Right email ->
                    case passwordResult of 
                        
                        Left passwordError ->
                            pure (Left (InvalidPassword passwordError))

                        Right password -> do
                            -- antes não tinha porque nem tinha passado pela cabeça, mas não é pra ter dois emails iguais kkkkk
                            
                            existingUser <- findUserByEmail (emailText email)

                            case existingUser of
                                Just _ ->
                                    pure (Left EmailAlreadyExists)

                                Nothing -> do
                                    passwordHash <- hashPassword password
                                    idOfUser <- generateUserId

                                    let user = User { 
                                        userId = idOfUser, 
                                        userEmail = email,
                                        userPasswordHash = passwordHash,
                                        userName = name,
                                        userRole = Customer
                                        }

                                    saveUser user
                                    pure (Right user)