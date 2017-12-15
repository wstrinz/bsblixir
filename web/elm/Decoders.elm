module Decoders exposing (..)

import Json.Decode as JD
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required, requiredAt)
import Json.Encode as JE
import Types exposing (..)


storyDecoder : JD.Decoder Story
storyDecoder =
    decode Story
        |> required "title" JD.string
        |> optional "author" JD.string ""
        |> optional "summary" JD.string ""
        |> optional "body" JD.string ""
        |> required "updated" JD.string
        |> required "url" JD.string
        |> required "read" JD.bool
        |> required "score" JD.float
        |> required "id" JD.int


feedAddEncoder : Model -> JE.Value
feedAddEncoder model =
    JE.object [ ( "url", JE.string model.feedToAdd ) ]


storyEncoder : Story -> JE.Value
storyEncoder story =
    JE.object
        [ ( "id", JE.int story.id )
        , ( "story"
          , JE.object
                [ ( "read", JE.bool story.read )
                ]
          )
        ]


feedEncoder : Feed -> JE.Value
feedEncoder feed =
    JE.object
        [ ( "id", JE.int feed.id )
        , ( "feed"
          , JE.object
                [ ( "base_score", JE.float feed.base_score )
                , ( "decay_per_hour", JE.float feed.decay_per_hour )
                ]
          )
        ]


feedDecoder : JD.Decoder Feed
feedDecoder =
    decode Feed
        |> required "title" JD.string
        |> optional "description" JD.string ""
        |> required "url" JD.string
        |> required "feed_url" JD.string
        |> required "updated" JD.string
        |> required "id" JD.int
        |> required "base_score" JD.float
        |> required "decay_per_hour" JD.float


feedRespDecoder : JD.Decoder Feed
feedRespDecoder =
    JD.at [ "data" ] feedDecoder


storyListDecorder : JD.Decoder (List Story)
storyListDecorder =
    JD.at [ "data" ] (JD.list storyDecoder)


feedListDecoder : JD.Decoder (List Feed)
feedListDecoder =
    JD.at [ "data" ] (JD.list feedDecoder)


storyRespDecoder : JD.Decoder Story
storyRespDecoder =
    JD.at [ "data" ] storyDecoder
