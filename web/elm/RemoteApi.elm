module RemoteApi exposing (..)

import Http
import Types exposing (..)
import Decoders exposing (..)
import Maybe.Extra


addFeed : Model -> Cmd Msg
addFeed model =
    Http.send AddFeedResponse <| Http.post "/feeds" (Http.jsonBody (feedAddEncoder model)) feedRespDecoder


getStories : Maybe Float -> Model -> Cmd Msg
getStories maybeMaxScore model =
    let
        feedPart =
            case model.currentFeed of
                Just feed ->
                    Just ("feed=" ++ toString feed.id)

                Nothing ->
                    Nothing

        scorePart =
            case maybeMaxScore of
                Just score ->
                    Just <| "maxScore=" ++ toString score

                Nothing ->
                    Nothing

        url =
            buildUrl "/stories" [ feedPart, scorePart ]
    in
        Http.send LoadStory <| Http.get url storyListDecorder


buildUrl : String -> List (Maybe String) -> String
buildUrl baseUrl params =
    let
        presentParts =
            Maybe.Extra.values params
    in
        case List.length presentParts of
            0 ->
                baseUrl

            _ ->
                baseUrl ++ "?" ++ String.join "&" presentParts


updateStory : Bool -> Story -> Cmd Msg
updateStory updateScore story =
    Http.send (UpdateStoryResponse updateScore) <| Http.post ("/stories/" ++ (toString story.id)) (Http.jsonBody (storyEncoder story)) storyRespDecoder


updateFeed : Feed -> Cmd Msg
updateFeed feed =
    Http.send UpdateFeedResponse <| Http.post ("/feeds/" ++ (toString feed.id)) (Http.jsonBody (feedEncoder feed)) feedRespDecoder
