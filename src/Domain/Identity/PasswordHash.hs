module Domain.Identity.PasswordHash where

import qualified Data.Text as Text
import Data.Text (Text)
import Domain.Password
import Domain.SharedStates

newtype PasswordHash = MakePasswordHash Text
    deriving (Eq, Show)

hashPassword :: Password Validated -> IO PasswordHash
hashPassword _ = pure (MakePasswordHash (Text.pack("PLACEHOLDER")))
