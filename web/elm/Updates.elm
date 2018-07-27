module Updates exposing (..)

import Decoders exposing (..)
import Http
import Models exposing (..)
import Types exposing (..)
import Ports
import Task
import Dict as D exposing (Dict)
import RemoteApi as Api


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        noChange =
            ( model, Cmd.none )
    in
        case msg of
            FetchStory maybeMaxScore ->
                ( model, Api.getStories maybeMaxScore model )

            LoadStory (Ok storyData) ->
                ( { model | stories = D.union model.stories (storyListToDict storyData) }, Cmd.none )

            LoadStory (Err e) ->
                ( { model | stories = D.singleton -1 (errStory e) }, Cmd.none )

            AddFeed ->
                ( { model | requestStatus = { status = "adding " ++ model.feedToAdd } }, Api.addFeed model )

            AddFeedResponse (Ok feedResp) ->
                ( { model | requestStatus = { status = "added feed" } }, Cmd.none )

            AddFeedResponse (Err feedResp) ->
                ( { model | requestStatus = { status = "failed to add feed! " ++ (toString feedResp) } }, Cmd.none )

            SetFeedToAdd feedUrl ->
                ( { model | feedToAdd = feedUrl }, Cmd.none )

            UpdateStory updateScore story ->
                ( { model | requestStatus = { status = "updating story " ++ (toString story) } }, Api.updateStory updateScore story )

            UpdateStoryResponse updateScore (Ok storyResp) ->
                let
                    currScore =
                        case model.currentStory of
                            Just story ->
                                story.score

                            Nothing ->
                                storyResp.score

                    updatedStory =
                        case updateScore of
                            True ->
                                storyResp

                            False ->
                                { storyResp | score = currScore }

                    updatedStories =
                        updateStoryList updatedStory model.stories
                in
                    ( { model | requestStatus = { status = "updated story " ++ (toString storyResp) }, stories = updatedStories, currentStory = reloadCurrent updatedStories model.currentStory }, Cmd.none )

            UpdateStoryResponse updateScore (Err storyResp) ->
                ( { model | requestStatus = { status = "update story failed! " ++ (toString storyResp) } }, Cmd.none )

            MarkStory story ->
                ( model
                , markStoryTask (Just story) (not story.read)
                )

            NextStory ->
                let
                    storyList =
                        storyDictToList <| Models.currentStories model

                    newCurr =
                        nextOrHead model.currentStory storyList
                in
                    ( { model | currentStory = newCurr }, markStoryAndFetchMoreIfNeeded newCurr storyList )

            PrevStory ->
                let
                    newCurr =
                        nextOrHead model.currentStory (List.reverse <| storyDictToList <| Models.currentStories model)
                in
                    ( { model | currentStory = newCurr }, Cmd.none )

            ToggleControlPanel ->
                ( { model | controlPanelVisible = not model.controlPanelVisible }, Cmd.none )

            OpenStory story ->
                ( model, Ports.openUrl story.url )

            SelectStory maybeStory ->
                case maybeStory of
                    Nothing ->
                        noChange

                    Just story ->
                        ( { model | currentStory = Just story }
                        , markStoryAndFetchMoreIfNeeded (Just story) (storyDictToList <| Models.currentStories model)
                        )

            SetView view ->
                ( { model | currentView = view }, Cmd.none )

            Noop ->
                ( model, Cmd.none )

            SetStoryDisplayType newType ->
                ( { model | storyDisplayType = newType }, Cmd.none )

            SetCurrentFeed maybeFeed ->
                ( { model
                    | currentFeed = maybeFeed
                    , currentView = StoryView
                    , controlPanelVisible = False
                  }
                , Cmd.none
                )

            FetchFeeds ->
                ( model, getFeeds )

            LoadFeeds (Ok feedsData) ->
                ( { model | feeds = (feedListToDict feedsData) }
                , Cmd.none
                )

            LoadFeeds (Err e) ->
                Debug.crash "TODO: handle feed fetch error"

            UpdateFeedModel updateType feed value ->
                case updateType of
                    BaseScore ->
                        ( updateFeedBaseScore feed value |> updateFeedModel model, Cmd.none )

                    DecayRate ->
                        ( updateFeedDecayRate feed value |> updateFeedModel model, Cmd.none )

            UpdateFeed feed ->
                ( { model | requestStatus = { status = "updating story " ++ (toString feed) } }, Api.updateFeed feed )

            UpdateFeedResponse (Ok feedResp) ->
                let
                    updatedModel =
                        updateFeedModel model feedResp
                in
                    ( { updatedModel | requestStatus = { status = "updated feed " ++ (toString feedResp) } }, Cmd.none )

            UpdateFeedResponse (Result.Err e) ->
                Debug.crash <| "feed update error " ++ toString e

            SetShowDebug showBool ->
                ( { model | showDebug = showBool }, Cmd.none )


markStoryAndFetchMoreIfNeeded : Maybe Story -> List Story -> Cmd Msg
markStoryAndFetchMoreIfNeeded currentStory storyList =
    let
        remainingStories =
            List.length <| findRest currentStory storyList

        --  <|
    in
        case remainingStories > 2 of
            True ->
                markStoryTask currentStory True

            False ->
                Cmd.batch [ markStoryTask currentStory True, loadMoreStoriesTask currentStory ]


updateFeedDecayRate : Feed -> String -> Feed
updateFeedDecayRate feed value =
    case String.toFloat value of
        Ok v ->
            { feed | decay_per_hour = v }

        Err _ ->
            feed


updateFeedBaseScore : Feed -> String -> Feed
updateFeedBaseScore feed value =
    case String.toFloat value of
        Ok v ->
            { feed | base_score = v }

        Err _ ->
            feed


updateFeedModel : Model -> Feed -> Model
updateFeedModel model feed =
    { model | feeds = D.insert feed.id feed model.feeds }


markStoryTask : Maybe Story -> Bool -> Cmd Msg
markStoryTask story readVal =
    case story of
        Nothing ->
            Cmd.none

        Just s ->
            Task.perform (UpdateStory False) (Task.succeed { s | read = readVal })


loadMoreStoriesTask : Maybe Story -> Cmd Msg
loadMoreStoriesTask story =
    case story of
        Nothing ->
            Cmd.none

        Just s ->
            Task.perform (\x -> FetchStory <| Just s.score) (Task.succeed s)


updateIfMatches : Story -> Story -> Story
updateIfMatches target current =
    case target.id == current.id of
        True ->
            target

        False ->
            current


updateStoryList : Story -> StoryDict -> StoryDict
updateStoryList story stories =
    D.insert story.id story stories


insertOrUpdateStory : Model -> Story -> Model
insertOrUpdateStory model story =
    { model | stories = D.insert story.id story model.stories }


currentOrFirstStory : Model -> List Story -> Maybe Story
currentOrFirstStory model stories =
    let
        sortedStories =
            List.reverse <| List.sortWith storySort stories
    in
        case model.currentStory of
            Just s ->
                model.currentStory

            Nothing ->
                nextOrHead model.currentStory sortedStories


reloadCurrent : StoryDict -> Maybe Story -> Maybe Story
reloadCurrent stories currentStory =
    case currentStory of
        Nothing ->
            Nothing

        Just s ->
            D.get s.id stories


getFeeds : Cmd Msg
getFeeds =
    Http.send LoadFeeds <| Http.get "/feeds" feedListDecoder
