module Views exposing (..)

import Html exposing (div, text)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (href, style, placeholder)
import Json.Encode
import Models exposing (findNext, findRest, storyDictToList)
import Types exposing (Model, Story, Feed, Msg(..), StoryDisplayType(..))
import Dict as D


rawHtml : String -> Html.Attribute msg
rawHtml str =
    (Html.Attributes.property "innerHTML" (Json.Encode.string str))


controls : Model -> Html.Html Msg
controls model =
    case model.controlPanelVisible of
        False ->
            div [] [ Html.button [ onClick ToggleControlPanel ] [ text "Show Controls" ] ]

        True ->
            div []
                [ Html.button [ onClick ToggleControlPanel ] [ text "Hide Controls" ]
                , Html.br [] []
                , Html.button [ onClick FetchStory ] [ text "fetch" ]
                , Html.br [] []
                , Html.input [ onInput SetFeedToAdd ] []
                , Html.button [ onClick AddFeed ] [ text "add" ]
                , Html.br [] []
                , Html.button [ onClick <| SetView Types.StoryView ] [ text "Stories" ]
                , Html.button [ onClick <| SetView Types.FeedsView ] [ text "Feeds" ]
                , Html.p [] [ text model.requestStatus.status ]
                , Html.button [ onClick PrevStory ] [ text "-" ]
                , Html.button [ onClick NextStory ] [ text "+" ]
                , Html.br [] []
                ]


storyDiv : Model -> Story -> Html.Html Msg
storyDiv model story =
    let
        baseStyle =
            [ ( "padding", "10px" ) ]

        commonAttrs =
            [ onClick <| SelectStory <| Just story ]

        attrs =
            if model.currentStory == Just story then
                [ style <| List.append baseStyle [ ( "border", "2px solid #000" ) ] ]
            else
                [ style baseStyle ]

        titleAttrs s =
            case s.read of
                True ->
                    [ style [ ( "color", "#636363" ) ] ]

                False ->
                    [ style [] ]

        displayContent story =
            case story.content of
                "" ->
                    story.summary

                _ ->
                    story.content

        contentArea =
            case model.storyDisplayType of
                Full ->
                    [ rawHtml <| displayContent story ]

                Titles ->
                    []
    in
        div (List.concat [ commonAttrs, attrs ])
            [ Html.h2 (titleAttrs story)
                [ Html.a [ href story.url, style [ ( "color", "inherit" ) ] ]
                    [ text story.title ]
                ]
            , Html.h4 [] [ text story.author ]
            , Html.p [] [ text <| story.updated ++ " (" ++ (toString story.score) ++ ")" ]
            , Html.p contentArea []
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
        [ Html.h3 [] [ text <| feed.title ]
        , inputEl feed.decay_per_hour <| UpdateFeedModel Types.DecayRate feed
        , inputEl feed.base_score <| UpdateFeedModel Types.BaseScore feed
        , Html.button [ onClick <| UpdateFeed feed ] [ text "Save" ]
        ]


feedsView : Model -> Html.Html Msg
feedsView model =
    let
        feedList =
            List.map Tuple.second <| D.toList model.feeds
    in
        div []
            [ Html.h2 [] [ text "Feeds" ]
            , div [] <| List.map (feedDiv model) feedList
            ]


storyView : Model -> Html.Html Msg
storyView model =
    let
        curr =
            model.currentStory

        restStories =
            storyDictToList model.stories |> findRest curr |> List.take 20

        shownStories =
            case curr of
                Just s ->
                    s :: restStories

                Nothing ->
                    restStories
    in
        div [] <| List.map (storyDiv model) shownStories


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
            , mainArea model
            ]
