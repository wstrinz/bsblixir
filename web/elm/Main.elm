module Main exposing (..)

import Char
import Html
import Keyboard
import Models exposing (Model, Msg(..), initialModel, currStory)
import Updates exposing (getStories, update)
import Views exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, getStories )
        , view = view
        , update = update
        , subscriptions = \model -> Keyboard.presses (actionForKeypress model)
        }


actionForKeypress : Model -> Int -> Msg
actionForKeypress model code =
    case Char.fromCode code of
        'j' ->
            NextStory

        'k' ->
            PrevStory

        'u' ->
            MarkStory <| currStory model

        k ->
            Debug.log (toString k) Noop
