module Updates exposing (..)

import Decoders exposing (..)
import Http
import Models exposing (..)
import Ports
import Task


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchStory ->
            ( model, getStories )

        LoadStory (Ok storyData) ->
            ( { model | stories = storyData, currentStory = currentOrFirstStory model storyData }
            , markStoryTask (List.head storyData) True
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
            ( { model | requestStatus = { status = "updated story" }, stories = updateStoryList storyResp model.stories }, Cmd.none )

        UpdateStoryResponse (Err storyResp) ->
            ( { model | requestStatus = { status = "update story failed! " ++ (toString storyResp) } }, Cmd.none )

        MarkStory story ->
            ( model
            , markStoryTask (Just story) (not story.read)
            )

        NextStory ->
            let
                newCurr =
                    nextOrHead model.currentStory model.stories
            in
                ( { model | currentStory = newCurr }, markStoryTask newCurr True )

        PrevStory ->
            let
                newCurr =
                    nextOrHead model.currentStory (List.reverse model.stories)
            in
                ( { model | currentStory = newCurr }, Cmd.none )

        ToggleControlPanel ->
            ( { model | controlPanelVisible = not model.controlPanelVisible }, Cmd.none )

        OpenStory story ->
            ( model, Ports.openUrl story.url )

        Noop ->
            ( model, Cmd.none )


markStoryTask : Maybe Story -> Bool -> Cmd Msg
markStoryTask story readVal =
    case story of
        Nothing ->
            Cmd.none

        Just s ->
            Task.perform UpdateStory (Task.succeed { s | read = readVal })


updateIfMatches : Story -> Story -> Story
updateIfMatches target current =
    case target.id == current.id of
        True ->
            target

        False ->
            current


updateStoryList : Story -> List Story -> List Story
updateStoryList story storyList =
    List.map (updateIfMatches story) storyList


insertOrUpdateStory : Model -> Story -> Model
insertOrUpdateStory model story =
    let
        storyInModel =
            not <| (List.filter (\i -> i.id == story.id) model.stories) == []
    in
        case storyInModel of
            True ->
                { model | stories = updateStoryList story model.stories }

            False ->
                { model | stories = story :: model.stories }


addFeed : Model -> Cmd Msg
addFeed model =
    Http.send AddFeedResponse <| Http.post "/feeds" (Http.jsonBody (feedAddEncoder model)) feedRespDecoder


getStories : Cmd Msg
getStories =
    Http.send LoadStory <| Http.get "/stories" storyListDecorder


updateStory : Story -> Cmd Msg
updateStory story =
    Http.send UpdateStoryResponse <| Http.post ("/stories/" ++ (toString story.id)) (Http.jsonBody (storyEncoder story)) storyRespDecoder


currentOrFirstStory : Model -> List Story -> Maybe Story
currentOrFirstStory model stories =
    case model.currentStory of
        Just s ->
            model.currentStory

        Nothing ->
            nextOrHead model.currentStory stories
