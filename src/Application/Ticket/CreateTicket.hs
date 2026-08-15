{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Application.Ticket.CreateTicket (CreateTicketRequest(..), createTicket) where

import GHC.Generics
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

-- precisamos da conversão que transforma JSON em tipos, por isso fazemos isso para cada um dos tipos utilizados por CreateTicketRequest
instance FromJSON TicketPriority where
    parseJSON = withText "TicketPriority" $ \value ->
        case value of
            "Low" -> pure Low
            "Normal" -> pure Normal
            "High" -> pure High
            _ -> fail "Invalid priority"

instance FromJSON TicketCategory where
    parseJSON = withText "TicketCategory" $ \value ->
        case value of
            "Network" -> pure Network
            "Account" -> pure Account
            "Printer" -> pure Printer
            "Hardware" -> pure Hardware
            "Other" -> pure Other
            _ -> pure Other

-- agora mapeamos a instância para CreateTicketRequest, para transformar JSON em tipos, ele pega o que o suposto front-end pode enviar
instance FromJSON CreateTicketRequest where
    parseJSON = withObject "CreateTicketRequest" $ \object -> do
        title <- object .: "title"
        description <- object .: "description"
        priority <- object .: "priority"
        category <- object .: "category"
        createdByText <- object .: "createdBy"

        case makeUserId createdByText of
            Nothing -> fail "Invalid userId"
            Just createdBy ->
                pure (CreateTicketRequest title description priority category createdBy)
