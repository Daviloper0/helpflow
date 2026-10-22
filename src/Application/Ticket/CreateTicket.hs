{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
module Application.Ticket.CreateTicket (CreateTicketRequest(..), CreateTicketError(..), createTicket) where

import Data.Aeson
import Data.Text (Text)

import Domain.Ticket.Ticket
import Domain.Identity.UserId

import Infrastructure.Ticket.TicketRepository

-- nem todos os campos são necessários, alguns são gerados, como o ticketId, ticketStatus e ticketAssignedTo e outros dependem do estado
data CreateTicketRequest = CreateTicketRequest
    {
        requestTitle       :: String,
        requestDescription :: String,
        requestPriority    :: Text,
        requestCategory    :: TicketCategory,
        requestCreatedBy   :: Text
    }
    deriving (Eq, Show)

data CreateTicketError = InvalidUserId | InvalidPriority
    deriving (Eq, Show)

parsePriority :: Text -> Maybe TicketPriority
parsePriority "Low"    = Just Low
parsePriority "Normal" = Just Normal
parsePriority "High"   = Just High
parsePriority _        = Nothing

-- temos a garantia de que todo ticket criado começa com Open, ou retorna um erro de userId ou priority inválidos
createTicket :: CreateTicketRequest -> IO (Either CreateTicketError (Ticket 'Open))
createTicket request =
    case parsePriority (requestPriority request) of
        Nothing -> pure (Left InvalidPriority)
        Just priority ->
            case makeUserId (requestCreatedBy request) of
                Nothing -> pure (Left InvalidUserId)
                Just createdBy -> do
                    let newTicket = createOpenTicket
                            (requestTitle request)
                            (requestDescription request)
                            priority
                            (requestCategory request)
                            createdBy
                    fmap Right (saveTicket newTicket)

-- agora mapeamos a instância para CreateTicketRequest, sem validar priority nem userId aqui
instance FromJSON CreateTicketRequest where
    parseJSON = withObject "CreateTicketRequest" $ \jsonPayload -> do
        title <- jsonPayload .: "title"
        description <- jsonPayload .: "description"
        priority <- jsonPayload .: "priority"
        category <- jsonPayload .: "category"
        createdBy <- jsonPayload .: "createdBy"
        pure (CreateTicketRequest title description priority category createdBy)
