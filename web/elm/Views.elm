module Views exposing (..)

import Html exposing (div, text)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (href, style)
import Json.Encode
import Models exposing (Model, Story, Msg(..), currStory, findNext)


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


storyDiv : Model -> Story -> Html.Html Msg
storyDiv model story =
    let
        baseStyle =
            [ ( "padding", "10px" ) ]

        attrs =
            if model.currentStory == story.id then
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
            currStory model

        next =
            case findNext model.currentStory model.stories of
                Just s ->
                    s

                Nothing ->
                    Models.blankStory

        afterNext =
            case findNext next.id model.stories of
                Just s ->
                    s

                Nothing ->
                    Models.blankStory
    in
        div []
            [ controls model
            , div [] <| List.map (storyDiv model) [ curr, next, afterNext ]
            ]
