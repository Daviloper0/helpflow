{-# LANGUAGE DataKinds #-}

module Application.Ticket.SolveTicket (SolveTicketError(..), completeTicket) where

import Domain.Ticket.Ticket
import Infrastructure.Ticket.TicketRepository

data SolveTicketError =
      TicketNotFound
    | TicketNotInProgress
    deriving (Eq, Show)

completeTicket :: TicketId -> IO (Either SolveTicketError (Ticket 'Solved))
completeTicket ticketId = do
    ticket <- findTicketById ticketId

    case ticket of
        Nothing ->
            pure (Left TicketNotFound)

        Just _ -> do
            inProgressTicket <- findInProgressTicket ticketId

            case inProgressTicket of
                Nothing ->
                    pure (Left TicketNotInProgress)

                Just ticketInProgress -> do
                    let solvedTicket = solveTicket ticketInProgress

                    updateTicket solvedTicket
                    pure (Right solvedTicket)