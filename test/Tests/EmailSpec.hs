module Tests.EmailSpec (emailTests) where

import Test.Tasty
import Test.Tasty.HUnit
import qualified Data.Text as Text
import Domain.Email

emailTests :: TestTree
emailTests = testGroup "Testes de email"
    [
    testCase "Email Vazio" (
        validateEmail (makeNonValidatedEmail (Text.pack("")))
        @?= Left EmptyEmail
    ),
    testCase "Comeca com @" (
        validateEmail (makeNonValidatedEmail (Text.pack("@arrobanocomeco@gmail.com")))
        @?= Left StartsWithAt
    ),
    testCase "Comeca com ." (
        validateEmail (makeNonValidatedEmail (Text.pack(".haskelltemsintaxeestranhja@haskell.org")))
        @?= Left StartsWithDot
    ),
    --blablabla: se não deixasse esse caso no final em Domain/Email.hs, então alguns erros poderiam dar TooManyAts, enquanto existia um caso mais específico, por exemplo arrobanofinal@gmail.com@ daria tooManyAts, o que não é necessariamente mentira, mas existe um caso que mostra exatamente onde @ está
    testCase "Muitos @s" (
        validateEmail (makeNonValidatedEmail (Text.pack("naoqueromaisprogramar@@gmail.com")))
        @?= Left TooManyAts
    ),
    testCase "Termina com @" (
        validateEmail (makeNonValidatedEmail (Text.pack("porquequeeufuiinventardefazerisso@gmail.com@")))
        @?= Left EndsWithAt
    ),
    testCase "Termina com ." (
        validateEmail (makeNonValidatedEmail (Text.pack("desenvolvimentoguiadoatipos@ufabc.edu.br.")))
        @?= Left EndsWithDot
    )
    ]