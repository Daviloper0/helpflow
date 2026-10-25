# PROBLEMS

## FORMAT
`[ID] TITLE | STATUS | FILE(S)`
`WHEN:` trigger condition
`SYMPTOM:` what actually happens
`ROOT:` why
`FIX:` what was done
`NOT:` approaches that don't work / were rejected

RULE: always append new entries at the end. IDs must be incremental.

---

## [001] Non-JSON error on invalid UUID in request body | SOLVED
`WHEN:` FromJSON instance calls `fail` for invalid UUID (e.g. createdBy, technicianId)
`SYMPTOM:` Servant returns plain-text `Error in $.field: <msg>`, not JSON
`ROOT:` `fail` inside Aeson parser propagates as Servant's default body-parse error formatter, which is plain text
`FIX:` Store field as `Text` in request type; remove UUID validation from `FromJSON`; validate with `makeUserId` inside application function; return `Left InvalidXxx`; handler pattern-matches and calls `throwError (errorResponse ...)`
`NOT:` `ErrorFormatters` in Main.hs — user explicitly rejected this approach

## [002] Non-JSON error on invalid priority in request body | SOLVED
`WHEN:` FromJSON TicketPriority receives unknown string
`SYMPTOM:` Plain-text `Error in $.priority: Invalid priority`
`ROOT:` Same as [001] — `fail` in FromJSON
`FIX:` Store `requestPriority :: Text`; add `parsePriority :: Text -> Maybe TicketPriority` in CreateTicket.hs; validate in `createTicket`; return `Left InvalidPriority`; handler throws `INVALID_PRIORITY`
`NOT:` ErrorFormatters in Main.hs

## [003] Non-JSON error on invalid ticketId in URL capture | SOLVED
`FILES:` API/AssignTicket.hs, API/SolveTicket.hs, API/API.hs, Domain/Ticket/Ticket.hs
`WHEN:` Non-integer string passed as ticketId path segment
`SYMPTOM:` Plain-text error before handler runs
`ROOT:` `FromHttpApiData TicketId` returns `Left` → Servant's URL parse error formatter (plain text)
`FIX:` Change `Capture "ticketId" TicketId` → `Capture "ticketId" Text` in API type; add `makeTicketIdFromText :: Text -> Maybe TicketId` to Domain.Ticket.Ticket; both handlers validate at top and throw `INVALID_TICKET_ID`
`NOT:` ErrorFormatters in Main.hs

## [004] Non-JSON error on invalid UUID in URL capture (promote/demote/assign) | SOLVED
`FILES:` API/PromoteToTechnician.hs, API/DemoteToUser.hs, API/AssignTicket.hs (technicianId in body), API/API.hs
`WHEN:` Invalid UUID passed as administratorId, targetUserId (path), or technicianId (body)
`SYMPTOM:` Plain-text error, no JSON
`ROOT:` Same as [001]/[003] depending on source (body vs capture)
`FIX:`
- Captures: `Capture "xId" UserId` → `Capture "xId" Text`; validate with `makeUserId` at handler top; throw `INVALID_USER_ID`
- Body (technicianId): `requestTechnicianId :: Text`; validate in `assignTicket`; added `InvalidTechnicianId` to `AssignTicketError`; handler throws `INVALID_TECHNICIAN_ID`
`NOT:` ErrorFormatters in Main.hs

## [005] Register/login latency ~1000ms | SOLVED
`WHEN:` Any operation touching password (register, login success, login failure)
`SYMPTOM:` 900–1000ms response time
`ROOT:` `BCrypt.slowerBcryptHashingPolicy` = cost 12 = 2^12 rounds, intentionally slow
`FIX:` Changed to `BCrypt.fastBcryptHashingPolicy` (cost 10 = 2^10 rounds) in Domain/Identity/PasswordHash.hs — ~250ms, 4x faster, acceptable for this project
`NOT:` DB or routing overhead (negligible); going below cost 10 is insecure
