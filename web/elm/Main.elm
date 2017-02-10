module Main exposing (..)

import Html exposing (div, text)


type alias Model =
    { title : String, author : String, content : String }


type Msg
    = Noop
    | LoadStories


initialModel : Model
initialModel =
    { title = "A story", author = "Me", content = "this is some story content" }


main : Program Never Model msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


update : a -> b -> ( b, Cmd msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html.Html msg
view model =
    div []
        [ Html.h2 [] [ text model.title ]
        , Html.h4 [] [ text model.author ]
        , Html.p [] [ text model.content ]
        ]
