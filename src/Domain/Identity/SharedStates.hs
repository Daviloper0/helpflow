{-# LANGUAGE DataKinds #-}

module Domain.Identity.SharedStates (ValidationState(..)) where
{-Decidi criar esse arquivo pois estava ficando muito repetitivo -}

data ValidationState = Validated | NonValidated
{-Suponho que talvez fosse uma alternativa melhor fazer como na atividade 4, que tinha o CheckStringClass e tudo mais,
mas na implementação, acredito que esteja amarrado o suficiente-}

{-Agora já não sei o que eu queria dizer com o outro comentário, mas decidi usar Data Kinds agora
Sinceramente eu nem tinha raciocinado, mas deixa muito mais amarrado, pois antes tinha um state genérico
em Name, Email, etc, agora ele só pode ser Validated ou NonValidated-}