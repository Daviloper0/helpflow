{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}

module Infrastructure.Ticket.TicketRepository (saveTicket, findOpenTicket, findInProgressTicket, updateTicket, findTicketById) where

import Data.Text(Text)
import qualified Data.Text as Text
import Database.Persist
import Database.Persist.Sqlite

import Domain.Ticket.Ticket
import Domain.Identity.UserId
import Domain.Identity.User

import Infrastructure.Database

saveTicket :: NewTicket status -> IO (Ticket status)
saveTicket ticket =
    runSqlite "helpflow.db" $ do
        generatedKey <- insert (ticketToEntity ticket) -- esse insert insere TicketEntity no banco de dados e retorna a chave
        pure (ticketFromEntity (makeTicketId (fromIntegral (fromSqlKey generatedKey))) ticket) -- E então pegamos a chave e transformamos em TicketId


{-Converte ticket para TicketEntity, precisamos disso pois o Persistent pede um TicketEntity para representar uma linha da tabela
a ideia é que dado um novo ticket, retorne o ticketentity
-}

ticketToEntity :: NewTicket status -> TicketEntity
ticketToEntity (NewOpenTicket title description priority category createdBy) =
    TicketEntity (Text.pack title) (Text.pack description) "Open" (Text.pack (show priority)) (Text.pack (show category)) (userIdToText createdBy) Nothing


ticketFromEntity :: TicketId -> NewTicket status -> Ticket status
ticketFromEntity generatedId (NewOpenTicket title description priority category createdBy) =
    OpenTicket generatedId title description priority category createdBy

-- útil para verificar as transições válidas
findTicketById :: TicketId -> IO (Maybe TicketEntity)
findTicketById ticketId =
    runSqlite "helpflow.db" $ do
        get (toSqlKey (fromIntegral (ticketIdToInt ticketId)) :: TicketEntityId)

{-Procura por ticket aberto apenas, dado um id de ticket, é útil porque só teremos um Ticket 'Open se realmente estiver aberto.-}
findOpenTicket :: TicketId -> IO (Maybe (Ticket 'Open))
findOpenTicket ticketId =
    runSqlite "helpflow.db" $ do
        result <- get (toSqlKey (fromIntegral (ticketIdToInt ticketId)) :: TicketEntityId)

        pure (result >>= ticketEntityToOpenTicket ticketId)

{-mesma coisa só que para 'InProgress-}
findInProgressTicket :: TicketId -> IO (Maybe (Ticket 'InProgress))
findInProgressTicket ticketId =
    runSqlite "helpflow.db" $ do
        result <- get (toSqlKey (fromIntegral (ticketIdToInt ticketId)) :: TicketEntityId)

        pure (result >>= ticketEntityToInProgressTicket ticketId)


{-Converte modelo do banco de dados para modelo do domínio, mas só para os abertos-}
ticketEntityToOpenTicket :: TicketId -> TicketEntity -> Maybe (Ticket 'Open)
ticketEntityToOpenTicket ticketId entity =
    if ticketEntityStatus entity == "Open"
        then do
            priority <- parsePriority (ticketEntityPriority entity)
            category <- parseCategory (ticketEntityCategory entity)
            createdBy <- makeUserId (ticketEntityCreatedBy entity)

            pure (OpenTicket ticketId (Text.unpack (ticketEntityTitle entity)) (Text.unpack (ticketEntityDescription entity)) priority category createdBy)
        else
            Nothing

{-Mesma coisa mas para InProgress-}
ticketEntityToInProgressTicket :: TicketId -> TicketEntity -> Maybe (Ticket 'InProgress)
ticketEntityToInProgressTicket ticketId entity =
    if ticketEntityStatus entity == "InProgress"
        then do
            priority <- parsePriority (ticketEntityPriority entity)
            category <- parseCategory (ticketEntityCategory entity)
            createdBy <- makeUserId (ticketEntityCreatedBy entity)
            assignedToText <- ticketEntityAssignedTo entity
            assignedToUserId <- makeUserId assignedToText

            pure (InProgressTicket ticketId (Text.unpack (ticketEntityTitle entity)) (Text.unpack (ticketEntityDescription entity)) priority category createdBy (TechnicianId assignedToUserId))
        else
            Nothing

--Finalmente afunção que atualiza o estado do ticket
updateTicket :: Ticket status -> IO ()
updateTicket ticket =
    runSqlite "helpflow.db" $ do
        let ticketId = toSqlKey (fromIntegral (ticketIdToInt (ticketIdFromTicket ticket))) :: TicketEntityId

        result <- get ticketId

        case result of
            Nothing ->
                pure ()

            Just entity ->
                replace ticketId (ticketEntityFromTicket entity ticket)

ticketEntityFromTicket :: TicketEntity -> Ticket status -> TicketEntity
ticketEntityFromTicket entity (OpenTicket _ _ _ _ _ _) =
    entity

ticketEntityFromTicket entity (InProgressTicket _ _ _ _ _ _ technicianId) =
    entity
        { 
            ticketEntityStatus = "InProgress",
            ticketEntityAssignedTo = Just (userIdToText (technicianIdToUserId technicianId))
        }

ticketEntityFromTicket entity (SolvedTicket _ _ _ _ _ _ technicianId) =
    entity
        { 
            ticketEntityStatus = "Solved",
            ticketEntityAssignedTo = Just (userIdToText (technicianIdToUserId technicianId))
        }


ticketIdFromTicket :: Ticket status -> TicketId
ticketIdFromTicket (OpenTicket ticketId _ _ _ _ _) =
    ticketId

ticketIdFromTicket (InProgressTicket ticketId _ _ _ _ _ _) =
    ticketId

ticketIdFromTicket (SolvedTicket ticketId _ _ _ _ _ _) =
    ticketId
    
parsePriority :: Text -> Maybe TicketPriority
parsePriority "Low" = Just Low
parsePriority "Normal" = Just Normal
parsePriority "High" = Just High
parsePriority _ = Nothing


parseCategory :: Text -> Maybe TicketCategory
parseCategory "Network" = Just Network
parseCategory "Account" = Just Account
parseCategory "Printer" = Just Printer
parseCategory "Hardware" = Just Hardware
parseCategory "Other" = Just Other
parseCategory _ = Nothing