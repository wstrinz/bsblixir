module Views exposing (..)

import Html exposing (div, text, a, br, button, h2)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (href, style, placeholder)
import Dict as D
import Types exposing (Model, Story, Feed, Msg(..), StoryDisplayType(..))
import Story.StoryView exposing (storyView)


controls : Model -> Html.Html Msg
controls model =
    case model.controlPanelVisible of
        False ->
            div [] [ button [ onClick ToggleControlPanel ] [ text "Show Controls" ] ]

        True ->
            div []
                [ button [ onClick ToggleControlPanel ] [ text "Hide Controls" ]
                , br [] []
                , button [ onClick FetchStory ] [ text "fetch" ]
                , br [] []
                , Html.input [ onInput SetFeedToAdd ] []
                , button [ onClick AddFeed ] [ text "add" ]
                , br [] []
                , button [ onClick <| SetView Types.StoryView ] [ text "Stories" ]
                , button [ onClick <| SetView Types.FeedsView ] [ text "Feeds" ]
                , Html.p [] [ text model.requestStatus.status ]
                , button [ onClick PrevStory ] [ text "-" ]
                , button [ onClick NextStory ] [ text "+" ]
                , br [] []
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
