module Decoders exposing (..)

import Json.Decode as JD
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required, requiredAt)
import Json.Encode as JE
import Models exposing (..)


storyDecoder : JD.Decoder Story
storyDecoder =
    decode Story
        |> required "title" JD.string
        |> required "author" JD.string
        |> optional "summary" JD.string ""
        |> optional "body" JD.string ""
        |> required "updated" JD.string
        |> required "url" JD.string
        |> required "id" JD.int


feedAddEncoder : Model -> JE.Value
feedAddEncoder model =
    JE.object
        [ ( "url", JE.string model.feedToAdd ) ]


feedDecoder : JD.Decoder Feed
feedDecoder =
    decode Feed
        |> required "title" JD.string
        |> optional "description" JD.string ""
        |> required "url" JD.string
        |> required "feed_url" JD.string
        |> required "updated" JD.string
        |> required "id" JD.int


feedRespDecoder : JD.Decoder Feed
feedRespDecoder =
    JD.at [ "data" ] feedDecoder


storyListDecorder : JD.Decoder (List Story)
storyListDecorder =
    JD.at [ "data" ] (JD.list storyDecoder)
