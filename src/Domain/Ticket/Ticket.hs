{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}

module Domain.Ticket.Ticket (createOpenTicket, ticketIdToInt, NewTicket(..), TicketId, TicketStatus(..), TicketPriority(..), TicketCategory(..), Ticket(..), makeTicketId) where

import Domain.Identity.UserId

newtype TicketId = TicketId Int 
    deriving (Eq, Ord, Show)

makeTicketId :: Int -> TicketId
makeTicketId = TicketId

ticketIdToInt :: TicketId -> Int 
ticketIdToInt (TicketId ticketId) = ticketId
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
    NextState 'Open       = 'InProgress
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
        -> String -- Titulo
        -> String -- Descrição
        -> TicketPriority
        -> TicketCategory
        -> UserId
        -> Maybe UserId
        -> Ticket 'InProgress

    SolvedTicket
        :: TicketId
        -> String -- Titulo
        -> String -- Descrição
        -> TicketPriority
        -> TicketCategory
        -> UserId
        -> Maybe UserId
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

{-Aqui utilizamos o type family criado lá em cima, o interessante é que o compilador infere o tipo baseado apenas no
tipo atual, porque definimos as transições anteriormente. Particularmente lembra os naturais de peano, talvez seja trauma-}
advanceTicket :: Ticket status -> Ticket (NextState status)
advanceTicket (OpenTicket ticketId' title description priority category createdBy) =
    InProgressTicket ticketId' title description priority category createdBy Nothing

advanceTicket (InProgressTicket ticketId' title description priority category createdBy assignedTo) =
    SolvedTicket ticketId' title description priority category createdBy assignedTo