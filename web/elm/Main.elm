module Main exposing (..)

import Char
import Html
import Keyboard
import Models exposing (Model, Msg(..), initialModel)
import Updates exposing (getStories, update)
import Views exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, getStories )
        , view = view
        , update = update
        , subscriptions = \_ -> Keyboard.presses actionForKeypress
        }


actionForKeypress : Int -> Msg
actionForKeypress code =
    case Char.fromCode code of
        'j' ->
            NextStory

        'k' ->
            PrevStory

        k ->
            Debug.log (toString k) Noop
