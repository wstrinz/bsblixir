module Main exposing (..)

import Html
import Updates exposing (update, getStories)
import Models exposing (Model, Msg(..), initialModel)
import Views exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, getStories )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
