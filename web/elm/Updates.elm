module Updates exposing (..)

import Http
import Json.Decode as JD
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required, requiredAt)
import Json.Encode as JE
import Models exposing (Feed, Model, Msg(..), Story, errStory, currStory, nextOrHead)


-- import Debug exposing (log)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchStory ->
            ( model, getStories )

        LoadStory (Ok storyData) ->
            ( { model | stories = storyData, currentStory = currentOrFirstStory model (List.reverse storyData) }
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
                    nextOrHead model.currentStory (List.reverse model.stories)
            in
                ( { model | currentStory = newCurr }, Cmd.none )

        PrevStory ->
            let
                newCurr =
                    nextOrHead model.currentStory model.stories
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


currentOrFirstStory : Model -> List Story -> Int
currentOrFirstStory model stories =
    case model.currentStory > 0 of
        True ->
            nextOrHead model.currentStory stories

        False ->
            model.currentStory
