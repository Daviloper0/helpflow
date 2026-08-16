{-# LANGUAGE OverloadedStrings #-}

module Domain.Identity.UserId (UserId, generateUserId, makeUserId, userIdToText) where
{-Decidi não inventar moda e usar um módulo que já existe, e nesse caso esse módulo UserId é 
quase que um wrapper das funções do UUID, com uma certa garantia nos tipos-}

import Data.Text (Text)
import qualified Data.UUID as UUID
import qualified Data.UUID.V4 as UUID
import Web.HttpApiData (FromHttpApiData(..))

newtype UserId = MakeUserId UUID.UUID
    deriving (Eq, Ord, Show)

generateUserId :: IO UserId
generateUserId =
    fmap MakeUserId (UUID.nextRandom)
    
makeUserId :: Text -> Maybe UserId
makeUserId text =
    fmap MakeUserId (UUID.fromText text)

userIdToText :: UserId -> Text
userIdToText (MakeUserId uuid) =
    UUID.toText uuid

-- não tinha essa instância, então não tinha como pegar o userId da url
instance FromHttpApiData UserId where
    parseUrlPiece text =
        case makeUserId text of
            Just userId -> Right userId
            Nothing -> Left "Invalid UserId"