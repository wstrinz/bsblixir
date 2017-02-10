module Main exposing (..)

import Html exposing (div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json


type alias Model =
    { title : String, author : String, content : String }


type Msg
    = Noop
    | LoadStory (Result Http.Error String)
    | FetchStory


initialModel : Model
initialModel =
    { title = "A story", author = "Me", content = "this is some story content" }


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


getStory : Cmd Msg
getStory =
    let
        storyUrl =
            "/stories/1"

        req =
            Http.get storyUrl decodeStoryData
    in
        Http.send LoadStory req


decodeStoryData : Json.Decoder String
decodeStoryData =
    Json.at [ "data", "title" ] Json.string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchStory ->
            ( model, getStory )

        LoadStory (Ok storyData) ->
            ( { model | title = storyData }
            , Cmd.none
            )

        LoadStory (Err _) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div []
        [ Html.h2 [] [ text model.title ]
        , Html.h4 [] [ text model.author ]
        , Html.p [] [ text model.content ]
        , Html.button [ onClick FetchStory ] [ text "load" ]
        ]
