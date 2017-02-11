module Updates exposing (..)

import Http
import Json.Decode as Json
import Json.Decode.Pipeline exposing (decode, required, requiredAt, optional, hardcoded)
import Models exposing (Msg(..), Model, errStory, Story)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchStory ->
            ( model, getStory )

        LoadStory (Ok storyData) ->
            ( { model | stories = storyData }
            , Cmd.none
            )

        LoadStory (Err e) ->
            ( { model | stories = [ errStory e ] }, Cmd.none )

        _ ->
            ( model, Cmd.none )


getStory : Cmd Msg
getStory =
    let
        storyUrl =
            "/stories"

        req =
            Http.get storyUrl storyListDecorder
    in
        Http.send LoadStory req


storyDecoder : Json.Decoder Story
storyDecoder =
    decode Story
        |> required "title" Json.string
        |> required "author" Json.string
        |> optional "summary" Json.string ""
        |> optional "body" Json.string ""
        |> required "url" Json.string


storyListDecorder : Json.Decoder (List Story)
storyListDecorder =
    Json.at [ "data" ] (Json.list storyDecoder)
