module Updates exposing (..)

import Http
import Models exposing (..)
import Decoders exposing (..)


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


currentOrFirstStory : Model -> List Story -> Int
currentOrFirstStory model stories =
    case model.currentStory > 0 of
        True ->
            nextOrHead model.currentStory stories

        False ->
            model.currentStory
