# AGENTS

Notes for future sessions. Token-optimized. Append new learnings at the end.

---

## PROJECT
- Haskell + Servant API, BCrypt passwords, SQLite via Infrastructure layer
- Stack build: `stack build` — a `copyFile: permission denied` at the end means the exe is running, NOT a compile error
- Tests: `stack test`

## ARCHITECTURE PATTERN
Every feature follows this layered structure:
```
Domain/       — pure types, smart constructors, validation
Application/  — business logic, returns IO (Either ErrorType Result)
Infrastructure/ — DB access (find/save/update)
API/          — Handler, calls Application, pattern-matches Either, throwError on Left
```

## ERROR HANDLING RULE (critical)
**Never use `fail` in FromJSON or `Left` in FromHttpApiData to surface user-facing errors.**
All validation that needs a JSON error response must be moved out of parsing and into the application function or handler.

Pattern for body fields (UUID, enum):
1. Store raw field as `Text` in request type
2. Parse/validate inside application function → return `Left InvalidXxx`
3. Add constructor to error ADT
4. Handler pattern-matches and calls `throwError (errorResponse errXxx "ERROR_CODE" "message")`

Pattern for URL captures (TicketId, UserId):
1. `Capture "x" Text` in API type (not the domain type)
2. Validate at top of handler with `makeXxxFromText`
3. `throwError (errorResponse err400 "INVALID_X" "...")` on Nothing

**Do NOT use ErrorFormatters in Main.hs** — user explicitly rejected this.

## ADDING A NEW ENDPOINT
1. Add route to `API/API.hs` (use `Text` for all captures)
2. Create `Application/X.hs` with error ADT + function returning `IO (Either XError Result)`
3. Create `API/X.hs` with handler
4. Add handler to `API/Server.hs`
5. Wire imports

## ADDDING A NEW ERROR TYPE (promote/demote/assign pattern)
- Application file exports both the function and the error ADT
- Handler imports the ADT and pattern-matches exhaustively
- `errorResponse :: ServerError -> Text -> Text -> ServerError` is in `API/ErrorResponse.hs`

## USER PREFERENCES
- No changes to `Main.hs` unless strictly necessary and confirmed
- No comments explaining WHAT code does, only WHY when non-obvious
- No extra abstractions beyond what the task asks
- Honest "no" over fake solution
- PROBLEMS.md: read before every bug fix, append solutions at end, incremental IDs
