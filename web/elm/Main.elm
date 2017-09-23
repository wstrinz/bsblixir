module Main exposing (..)

import Char
import Html
import Keyboard
import Models exposing (initialModel)
import Types exposing (Model, Msg(..), StoryDisplayType(..))
import Updates exposing (getFeeds, update)
import RemoteApi exposing (getStories)
import Views exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.batch [ getStories, getFeeds ] )
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
            case model.currentStory of
                Just s ->
                    MarkStory <| s

                Nothing ->
                    Noop

        'o' ->
            case model.currentStory of
                Just s ->
                    OpenStory <| s

                Nothing ->
                    Noop

        'v' ->
            case model.storyDisplayType of
                Titles ->
                    SetStoryDisplayType Full

                Full ->
                    SetStoryDisplayType Titles

        k ->
            Debug.log (toString k) Noop
