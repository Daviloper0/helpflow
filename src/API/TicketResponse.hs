{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module API.TicketResponse (TicketResponse(..), ticketToResponse, ticketInProgressToResponse, ticketSolvedToResponse) where

import Data.Aeson

import Domain.Ticket.Ticket
import Domain.Identity.UserId
import Domain.Identity.User

data TicketResponse = TicketResponse -- resposta deve ter os mesmos parâmetros do que o ticket, obviamente
    {
        responseId          :: TicketId,
        responseTitle       :: String,
        responseDescription :: String,
        responseStatus      :: TicketStatus,
        responsePriority    :: TicketPriority,
        responseCategory    :: TicketCategory,
        responseCreatedBy   :: UserId,
        responseAssignedTo  :: Maybe UserId
    }
    deriving (Eq, Show)

-- transforma ticketresponse em json, para devolver para o front-end. Essa instância é justamente o que mapeia pro JSON
instance ToJSON TicketResponse where
    toJSON response =
        object
            [ 
              "id" .= ticketIdToInt (responseId response),
              "title" .= responseTitle response,
              "description" .= responseDescription response,
              "status" .= show (responseStatus response),
              "priority" .= show (responsePriority response),
              "category" .= show (responseCategory response),
              "createdBy" .= userIdToText (responseCreatedBy response),
              "assignedTo" .= fmap userIdToText (responseAssignedTo response)
            ]

-- ticketToResponse, utilizado no handler, pega o Ticket (que acabou de ser aberto) e transforma em uma resposta
ticketToResponse :: Ticket 'Open -> TicketResponse
ticketToResponse (OpenTicket ticketId' title description priority category createdBy) =
    TicketResponse
        { 
          responseId = ticketId',
          responseTitle = title,
          responseDescription = description,
          responseStatus = Open,
          responsePriority = priority,
          responseCategory = category,
          responseCreatedBy = createdBy,
          responseAssignedTo = Nothing
        }

-- mesma coisa que o anterior, mas para tickets em progresso
ticketInProgressToResponse :: Ticket 'InProgress -> TicketResponse
ticketInProgressToResponse (InProgressTicket ticketId' title description priority category createdBy technicianId) =
    TicketResponse
        { 
          responseId = ticketId',
          responseTitle = title,
          responseDescription = description,
          responseStatus = InProgress,
          responsePriority = priority,
          responseCategory = category,
          responseCreatedBy = createdBy,
          responseAssignedTo = Just (technicianIdToUserId technicianId)
        }

-- agora para tickets resolvidos
ticketSolvedToResponse :: Ticket 'Solved -> TicketResponse
ticketSolvedToResponse (SolvedTicket ticketId' title description priority category createdBy technicianId) =
    TicketResponse
        { 
          responseId = ticketId',
          responseTitle = title,
          responseDescription = description,
          responseStatus = Solved,
          responsePriority = priority,
          responseCategory = category,
          responseCreatedBy = createdBy,
          responseAssignedTo = Just (technicianIdToUserId technicianId)
        }