module Updates exposing (..)

import Decoders exposing (..)
import Http
import Models exposing (..)
import Task


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchStory ->
            ( model, getStories )

        LoadStory (Ok storyData) ->
            ( { model | stories = storyData, currentStory = currentOrFirstStory model storyData }
            , Cmd.none
            )

        LoadStory (Err e) ->
            ( { model | stories = [ errStory e ] }, Cmd.none )

        AddFeed ->
            ( { model | requestStatus = { status = "adding " ++ model.feedToAdd } }, addFeed model )

        AddFeedResponse (Ok feedResp) ->
            ( { model | requestStatus = { status = "added feed" } }, Cmd.none )

        AddFeedResponse (Err feedResp) ->
            ( { model | requestStatus = { status = "failed to add feed! " ++ (toString feedResp) } }, Cmd.none )

        SetFeedToAdd feedUrl ->
            ( { model | feedToAdd = feedUrl }, Cmd.none )

        UpdateStory story ->
            ( { model | requestStatus = { status = "updating story " ++ (toString story) } }, updateStory story )

        UpdateStoryResponse (Ok storyResp) ->
            ( { model | requestStatus = { status = "updated story" } }, Cmd.none )

        UpdateStoryResponse (Err storyResp) ->
            ( { model | requestStatus = { status = "update story failed! " ++ (toString storyResp) } }, Cmd.none )

        MarkStory story ->
            ( model
            , Task.perform UpdateStory (Task.succeed { story | read = True })
            )

        NextStory ->
            let
                newCurr =
                    nextOrHead model.currentStory model.stories
            in
                ( { model | currentStory = newCurr }, Cmd.none )

        PrevStory ->
            let
                newCurr =
                    nextOrHead model.currentStory (List.reverse model.stories)
            in
                ( { model | currentStory = newCurr }, Cmd.none )

        Noop ->
            ( model, Cmd.none )


addFeed : Model -> Cmd Msg
addFeed model =
    Http.send AddFeedResponse <| Http.post "/feeds" (Http.jsonBody (feedAddEncoder model)) feedRespDecoder


getStories : Cmd Msg
getStories =
    Http.send LoadStory <| Http.get "/stories" storyListDecorder


updateStory : Story -> Cmd Msg
updateStory story =
    Http.send UpdateStoryResponse <| Http.post ("/stories/" ++ (toString story.id)) (Http.jsonBody (storyEncoder story)) storyRespDecoder


currentOrFirstStory : Model -> List Story -> Int
currentOrFirstStory model stories =
    case model.currentStory > 0 of
        True ->
            nextOrHead model.currentStory stories

        False ->
            model.currentStory
