module RemoteApi exposing (..)

import Http
import Types exposing (..)
import Decoders exposing (..)
import Dict


addFeed : Model -> Cmd Msg
addFeed model =
    Http.send AddFeedResponse <| Http.post "/feeds" (Http.jsonBody (feedAddEncoder model)) feedRespDecoder


getStories : Cmd Msg
getStories =
    Http.send LoadStory <| Http.get "/stories" storyListDecorder


getMoreStories : Model -> Cmd Msg
getMoreStories model =
    let
        skipIds =
            model.stories |> Dict.values |> List.map .id |> List.map toString
    in
        Http.send LoadStory <| Http.get ("/stories" ++ "?skip=[" ++ String.join "," skipIds ++ "]") storyListDecorder


updateStory : Bool -> Story -> Cmd Msg
updateStory updateScore story =
    Http.send (UpdateStoryResponse updateScore) <| Http.post ("/stories/" ++ (toString story.id)) (Http.jsonBody (storyEncoder story)) storyRespDecoder


updateFeed : Feed -> Cmd Msg
updateFeed feed =
    Http.send UpdateFeedResponse <| Http.post ("/feeds/" ++ (toString feed.id)) (Http.jsonBody (feedEncoder feed)) feedRespDecoder
