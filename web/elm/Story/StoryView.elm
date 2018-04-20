module Story.StoryView exposing (storyView)

import Html exposing (text, div)
import Html.Attributes exposing (style, href)
import Html.Events exposing (onClick)
import Types exposing (..)
import Models
import Json.Encode
import Date.Extra as DE


rawHtml : String -> Html.Attribute msg
rawHtml str =
    (Html.Attributes.property "innerHTML" (Json.Encode.string str))


storyAttrs : Model -> Story -> List (Html.Attribute Msg)
storyAttrs model story =
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
    in
        (List.concat [ commonAttrs, attrs ])


storyTitle : Story -> Html.Html Msg
storyTitle story =
    let
        titleAttrs s =
            case s.read of
                True ->
                    [ style [ ( "color", "#636363" ) ] ]

                False ->
                    []
    in
        Html.h2 (titleAttrs story)
            [ Html.a [ href story.url, style [ ( "color", "inherit" ) ] ]
                [ text story.title ]
            ]


storySubHeader : Model -> Story -> Html.Html Msg
storySubHeader model story =
    let
        feedTitleString =
            case model.currentFeed of
                Just feed ->
                    ""

                Nothing ->
                    Models.feedTitleForStory model story ++ " - "
    in
        Html.h4
            [ onClick <| SetCurrentFeed <| Models.feedForStory model story, style [ ( "width", "fit-content" ) ] ]
            [ text <| feedTitleString ++ story.author ]


storyDate : Story -> Html.Html Msg
storyDate story =
    let
        formattedDate =
            case DE.fromIsoString story.updated of
                Ok date ->
                    DE.toFormattedString "h:mm a 'on' EEEE, MMMM d " <| DE.add DE.Hour -6 date

                Err _ ->
                    story.updated
    in
        Html.p [] [ text <| formattedDate ++ " (" ++ (toString story.score) ++ ")" ]


storyBody : Model -> Story -> Html.Html Msg
storyBody model story =
    let
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
        Html.p contentArea []


storyHeader : Model -> Story -> Html.Html Msg
storyHeader model story =
    div [ style [ ( "width", "fit-content" ) ] ]
        [ storyTitle story
        , storySubHeader model story
        , storyDate story
        ]


storyDiv : Model -> Story -> Html.Html Msg
storyDiv model story =
    div
        (storyAttrs model story)
        [ storyHeader model story
        , storyBody model story
        ]


storyView : Model -> Html.Html Msg
storyView model =
    let
        curr =
            model.currentStory

        restStories =
            Models.storyDictToList (Models.currentStories model)
                |> Models.findRest curr
                |> List.take 5

        shownStories =
            case curr of
                Just s ->
                    s :: restStories

                Nothing ->
                    restStories
    in
        div [] <| List.map (storyDiv model) shownStories
