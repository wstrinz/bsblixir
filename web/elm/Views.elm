module Views exposing (..)

import Dict as D
import Html exposing (a, br, button, div, h2, text)
import Html.Attributes exposing (href, placeholder, style)
import Html.Events exposing (onClick, onInput)
import Models
import Story.StoryView exposing (storyView)
import Types exposing (Feed, Model, Msg(..), Story, StoryDisplayType(..))


debugDiv : Model -> Html.Html Msg
debugDiv model =
    if model.showDebug then
        div []
            [ Html.p [] [ text model.requestStatus.status ]
            , Html.p [] [ text <| toString <| List.map (.title) <| Models.storyDictToList model.stories ]
            , Html.p [] [ text <| toString <| List.map (.title) <| Models.findRest model.currentStory <| Models.storyDictToList model.stories ]
            ]
    else
        div [] []


controls : Model -> Html.Html Msg
controls model =
    let
        debugToggle =
            if model.showDebug then
                button [ onClick <| SetShowDebug False ] [ text "Hide Debug" ]
            else
                button [ onClick <| SetShowDebug True ] [ text "Show Debug" ]
    in
        case model.controlPanelVisible of
            False ->
                div [] [ button [ onClick ToggleControlPanel ] [ text "Show Controls" ] ]

            True ->
                div []
                    [ button [ onClick ToggleControlPanel ] [ text "Hide Controls" ]
                    , br [] []
                    , button [ onClick <| FetchStory Nothing ] [ text "fetch" ]
                    , br [] []
                    , Html.input [ onInput SetFeedToAdd ] []
                    , button [ onClick AddFeed ] [ text "add" ]
                    , br [] []
                    , button [ onClick <| SetView Types.StoryView ] [ text "Stories" ]
                    , button [ onClick <| SetView Types.FeedsView ] [ text "Feeds" ]
                    , debugToggle
                    , debugDiv model
                    ]


appHeader : Model -> Html.Html Msg
appHeader model =
    case model.currentFeed of
        Nothing ->
            div [] []

        Just feed ->
            div []
                [ Html.h3 []
                    [ a [ href feed.url, style [ ( "color", "#000" ) ] ]
                        [ text feed.title ]
                    ]
                ]


feedEditView : Feed -> Model -> Html.Html Msg
feedEditView feed model =
    div []
        [ Html.h2 [] [ text "Feed Edit" ]
        ]


inputEl : a -> (String -> Msg) -> Html.Html Msg
inputEl placeholderValue action =
    Html.input [ Html.Attributes.placeholder <| toString placeholderValue, onInput action ] []


feedDiv : Model -> Feed -> Html.Html Msg
feedDiv model feed =
    div []
        [ Html.h3 []
            [ a [ onClick <| SetCurrentFeed <| Just feed ]
                [ text <| feed.title ++ " (" ++ (toString feed.unreadCount) ++ ")" ]
            ]
        , inputEl feed.decay_per_hour <| UpdateFeedModel Types.DecayRate feed
        , inputEl feed.base_score <| UpdateFeedModel Types.BaseScore feed
        , button [ onClick <| UpdateFeed feed ] [ text "Save" ]
        ]


feedsView : Model -> Html.Html Msg
feedsView model =
    let
        feedList =
            List.map Tuple.second <| D.toList model.feeds
    in
        div []
            [ Html.h2 [] [ text "Feeds" ]
            , div [] [ a [ onClick <| SetCurrentFeed Nothing ] [ text "All Feeds" ] ]
            , div [] <| List.map (feedDiv model) feedList
            ]


view : Model -> Html.Html Msg
view model =
    let
        mainArea =
            case model.currentView of
                Types.FeedsView ->
                    feedsView

                Types.StoryView ->
                    storyView

                Types.FeedView f ->
                    feedEditView f
    in
        div []
            [ controls model
            , appHeader model
            , mainArea model
            ]
