module RemoteApi exposing (..)

import Http
import Types exposing (..)
import Decoders exposing (..)


addFeed : Model -> Cmd Msg
addFeed model =
    Http.send AddFeedResponse <| Http.post "/feeds" (Http.jsonBody (feedAddEncoder model)) feedRespDecoder


getStories : Cmd Msg
getStories =
    Http.send LoadStory <| Http.get "/stories" storyListDecorder


updateStory : Bool -> Story -> Cmd Msg
updateStory updateScore story =
    Http.send (UpdateStoryResponse updateScore) <| Http.post ("/stories/" ++ (toString story.id)) (Http.jsonBody (storyEncoder story)) storyRespDecoder


updateFeed : Feed -> Cmd Msg
updateFeed feed =
    Http.send UpdateFeedResponse <| Http.post ("/feeds/" ++ (toString feed.id)) (Http.jsonBody (feedEncoder feed)) feedRespDecoder
