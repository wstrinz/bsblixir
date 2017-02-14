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
    div []
        [ Html.button [ onClick FetchStory ] [ text "load" ]
        , Html.br [] []
        , Html.input [ onInput SetFeedToAdd ] []
        , Html.button [ onClick AddFeed ] [ text "add" ]
        , Html.p [] [ text model.requestStatus.status ]
        , Html.button [ onClick PrevStory ] [ text "-" ]
        , Html.button [ onClick NextStory ] [ text "+" ]
        ]


storyDiv : Model -> Story -> Html.Html Msg
storyDiv model story =
    let
        attrs =
            if model.currentStory == story.id then
                [ style [ ( "border", "2px solid #000" ) ] ]
            else
                []
    in
        div attrs
            [ Html.h2 []
                [ Html.a [ href story.url ] [ text story.title ]
                ]
            , Html.h4 [] [ text story.author ]
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
    in
        div []
            [ controls model
            , div [] <| List.map (storyDiv model) [ curr, next ]
            ]
