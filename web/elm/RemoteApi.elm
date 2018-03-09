module RemoteApi exposing (..)

import Http
import Types exposing (..)
import Decoders exposing (..)


addFeed : Model -> Cmd Msg
addFeed model =
    Http.send AddFeedResponse <| Http.post "/feeds" (Http.jsonBody (feedAddEncoder model)) feedRespDecoder


getStories : Maybe Float -> Cmd Msg
getStories maybeMaxScore =
    let
        url =
            case maybeMaxScore of
                Just score ->
                    "/stories?maxScore=" ++ toString score

                Nothing ->
                    "/stories"
    in
        Http.send LoadStory <| Http.get url storyListDecorder


updateStory : Bool -> Story -> Cmd Msg
updateStory updateScore story =
    Http.send (UpdateStoryResponse updateScore) <| Http.post ("/stories/" ++ (toString story.id)) (Http.jsonBody (storyEncoder story)) storyRespDecoder


updateFeed : Feed -> Cmd Msg
updateFeed feed =
    Http.send UpdateFeedResponse <| Http.post ("/feeds/" ++ (toString feed.id)) (Http.jsonBody (feedEncoder feed)) feedRespDecoder
