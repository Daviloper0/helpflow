{-# LANGUAGE OverloadedStrings#-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}

module Infrastructure.Ticket.TicketRepository (saveTicket) where

import Data.Text(Text)
import qualified Data.Text as Text

import Database.Persist
import Database.Persist.Sqlite

import Infrastructure.Database

import Domain.Ticket.Ticket
import Domain.Identity.UserId


saveTicket :: NewTicket status -> IO (Ticket status)
saveTicket ticket =
    runSqlite "helpflow.db" $ do
        generatedKey <- insert (ticketToEntity ticket) -- esse insert insere TicketEntity no banco de dados e retorna a chave
        pure (ticketFromEntity (makeTicketId (fromIntegral (fromSqlKey generatedKey))) ticket) -- E então pegamos a chave e transformamos em TickedId


{-Converte ticket para TicketEntity, precisamos disso pois o Persistent pede um TicketEntity para representar uma linha da tabela
a ideia é que dado um novo ticket, retorne o ticketentity
-}

ticketToEntity :: NewTicket status -> TicketEntity
ticketToEntity (NewOpenTicket title description priority category createdBy) =
    TicketEntity (Text.pack title) (Text.pack description) "Open" (Text.pack (show priority)) (Text.pack (show category)) (userIdToText createdBy) Nothing


ticketFromEntity :: TicketId -> NewTicket status -> Ticket status
ticketFromEntity generatedId (NewOpenTicket title description priority category createdBy) =
    OpenTicket generatedId title description priority category createdBy