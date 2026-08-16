{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Application.Ticket.CreateTicket (CreateTicketRequest(..), createTicket) where

import Data.Aeson

import Domain.Ticket.Ticket
import Domain.Identity.UserId

import Infrastructure.Ticket.TicketRepository

-- nem todos os campos são necessários, alguns são gerados, como o ticketId, ticketStatus e ticketAssignedTo e outros dependem do estado
data CreateTicketRequest = CreateTicketRequest 
    { 
        requestTitle       :: String,
        requestDescription :: String,
        requestPriority    :: TicketPriority,
        requestCategory    :: TicketCategory,
        requestCreatedBy   :: UserId
    }
    deriving (Eq, Show)

-- temos a garantia de que todo ticket criado começa com Open
createTicket :: CreateTicketRequest -> IO (Ticket 'Open)
createTicket request = do
    let newTicket = createOpenTicket
            (requestTitle request)
            (requestDescription request)
            (requestPriority request)
            (requestCategory request)
            (requestCreatedBy request)

    saveTicket newTicket

-- agora mapeamos a instância para CreateTicketRequest, para transformar JSON em tipos, ele pega o que o suposto front-end pode enviar
instance FromJSON CreateTicketRequest where
    parseJSON = withObject "CreateTicketRequest" $ \jsonPayload -> do
        title <- jsonPayload .: "title"
        description <- jsonPayload .: "description"
        priority <- jsonPayload .: "priority"
        category <- jsonPayload .: "category"
        createdByText <- jsonPayload .: "createdBy"

        case makeUserId createdByText of
            Nothing -> fail "Invalid userId"
            Just createdBy ->
                pure (CreateTicketRequest title description priority category createdBy)
