{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}

module Domain.Ticket.Ticket (createOpenTicket, ticketIdToInt, NewTicket(..), TicketId, TicketStatus(..), TicketPriority(..), TicketCategory(..), Ticket(..), makeTicketId, makeTicketIdFromText, assignTicketToTechnician, solveTicket) where

import qualified Data.Text as Text
import Data.Text (Text)
import Data.Aeson
import Web.HttpApiData

import Domain.Identity.User
import Domain.Identity.UserId

newtype TicketId = TicketId Int 
    deriving (Eq, Ord, Show)

makeTicketId :: Int -> TicketId
makeTicketId = TicketId

makeTicketIdFromText :: Text -> Maybe TicketId
makeTicketIdFromText text =
    case reads (Text.unpack text) of
        [(n, "")] -> Just (TicketId n)
        _         -> Nothing

ticketIdToInt :: TicketId -> Int
ticketIdToInt (TicketId ticketId) = ticketId

-- é necessário converter o texto que sai do JSON (da requisição HTTP) e transforma em um ticketid

instance FromHttpApiData TicketId where
    parseUrlPiece text =
        case reads (Text.unpack text) of
            [(ticketId, "")] ->
                Right (makeTicketId ticketId)
            _ ->
                Left "Invalid ticketId"


data TicketStatus
    = Open
    | InProgress
    | Solved
    deriving (Eq, Show)

-- Categorias dos tickets, conforme protótipo do figma
data TicketCategory
    = Network
    | Account
    | Printer
    | Hardware
    | Other
    deriving (Eq, Show)

-- prioridade dos tickets
data TicketPriority
    = Low
    | Normal
    | High -- alto/urgente
    deriving (Eq, Show)

-- Utilizando type families para definir a transição de estados dos tickets, assim, nenhum ticket pode ir de open para resolved, sem passar por in progress, ou voltar um estado
type family NextState (status :: TicketStatus) :: TicketStatus where
    NextState 'Open = 'InProgress
    NextState 'InProgress = 'Solved

{-usamos kindsignatures para garantir que apenas status TicketStatus sejam válidos, e utilizamos GADTs para 
explicitar qual tipo de ticket cada construtor está criando,ou seja, cada construtor faz um ticket com estado específico-}
data Ticket (status :: TicketStatus) where
    OpenTicket :: 
        TicketId
        -> String -- Titulo
        -> String -- Descrição 
        -> TicketPriority
        -> TicketCategory
        -> UserId
        -> Ticket 'Open

    InProgressTicket
        :: TicketId
        -> String
        -> String
        -> TicketPriority
        -> TicketCategory
        -> UserId
        -> TechnicianId
        -> Ticket 'InProgress

    SolvedTicket
        :: TicketId
        -> String
        -> String
        -> TicketPriority
        -> TicketCategory
        -> UserId
        -> TechnicianId
        -> Ticket 'Solved

--Ticket que ainda não possui ID gerado pelo banco
data NewTicket (status :: TicketStatus) where
    NewOpenTicket ::
        String -- Titulo
        -> String -- Descrição
        -> TicketPriority
        -> TicketCategory
        -> UserId
        -> NewTicket 'Open

createOpenTicket :: String -> String -> TicketPriority -> TicketCategory -> UserId -> NewTicket 'Open
createOpenTicket title description priority category createdBy =
    NewOpenTicket title description priority category createdBy
    -- claramente criamos um ticket aberto, com os dados que já tinham sido definidos

{-
    apesar da ideia de usar um advanceTicket antes fosse legal, não faz muito sentido como decisão de negócio
    a ideia é que só possamos mudar o estado do ticket de open para inProgress dado um technicianId.
    
    então antes seria feito em uma função só, mas com pattern matching dos casos, agora vão ser funções separadas

    além disso, ainda é possível utilizar type families, então ainda temos garantia no nivel dos tipos
-}

assignTicketToTechnician :: TechnicianId -> Ticket 'Open -> Ticket (NextState 'Open)
assignTicketToTechnician technicianId (OpenTicket ticketId' title description priority category createdBy) =
    InProgressTicket ticketId' title description priority category createdBy technicianId

solveTicket :: Ticket 'InProgress -> Ticket 'Solved
solveTicket (InProgressTicket ticketId' title description priority category createdBy technicianId) =
    SolvedTicket ticketId' title description priority category createdBy technicianId

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