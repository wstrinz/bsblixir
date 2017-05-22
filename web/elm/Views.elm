module Views exposing (..)

import Html exposing (div, text)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (href, style)
import Json.Encode
import Models exposing (Model, Story, Msg(..), findNext, storyDictToList)


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
                [ Html.button [ onClick FetchStory ] [ text "fetch" ]
                , Html.br [] []
                , Html.input [ onInput SetFeedToAdd ] []
                , Html.button [ onClick AddFeed ] [ text "add" ]
                , Html.p [] [ text model.requestStatus.status ]
                , Html.button [ onClick PrevStory ] [ text "-" ]
                , Html.button [ onClick NextStory ] [ text "+" ]
                , Html.br [] []
                , Html.button [ onClick ToggleControlPanel ] [ text "Hide Controls" ]
                ]


storyDiv : Model -> Maybe Story -> Html.Html Msg
storyDiv model maybeStory =
    let
        baseStyle =
            [ ( "padding", "10px" ) ]

        attrs =
            if model.currentStory == maybeStory then
                [ style <| List.append baseStyle [ ( "border", "2px solid #000" ) ] ]
            else
                [ style baseStyle ]

        titleAttrs story =
            case story.read of
                True ->
                    [ style [ ( "color", "#636363" ) ] ]

                False ->
                    [ style [] ]
    in
        case maybeStory of
            Nothing ->
                div [] [ text ":( no story -> miscchange" ]

            Just story ->
                div attrs
                    [ Html.h2 (titleAttrs story)
                        [ Html.a [ href story.url, style [ ( "color", "inherit" ) ] ]
                            [ text story.title ]
                        ]
                    , Html.h4 [] [ text story.author ]
                    , Html.p [] [ text story.updated ]
                    , Html.p [ rawHtml story.summary ] []
                    , Html.p [ rawHtml story.content ] []
                    ]


view : Model -> Html.Html Msg
view model =
    let
        curr =
            model.currentStory

        next =
            findNext model.currentStory <| storyDictToList model.stories

        afterNext =
            findNext next <| storyDictToList model.stories
    in
        div []
            [ controls model
            , div [] <| List.map (storyDiv model) [ curr, next, afterNext ]
            ]
