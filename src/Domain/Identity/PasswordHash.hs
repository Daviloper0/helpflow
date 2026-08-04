{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}

module Domain.Identity.PasswordHash (PasswordHash, hashPassword, verifyPassword) where

import Data.Text (Text)
import qualified Data.Text.Encoding as Text
import qualified Crypto.BCrypt as BCrypt
import Domain.Identity.Password
import Domain.Identity.SharedStates


newtype PasswordHash = MakePasswordHash Text
    deriving (Eq, Show)

hashPassword :: Password 'Validated -> IO PasswordHash
{-hashPassword _ = 
    pure (MakePasswordHash (Text.pack("PLACEHOLDER")))
-}
hashPassword password = do
    hashed <- BCrypt.hashPasswordUsingPolicy
              BCrypt.slowerBcryptHashingPolicy
              (Text.encodeUtf8 (passwordText password))
    
    case hashed of
        Nothing -> error "Erro ao gerar hash da senha"
        Just hash -> pure (MakePasswordHash (Text.decodeUtf8 hash))

verifyPassword :: Password 'Validated -> PasswordHash -> Bool
verifyPassword password (MakePasswordHash hash) =
    BCrypt.validatePassword (Text.encodeUtf8 hash) (Text.encodeUtf8 (passwordText password))
