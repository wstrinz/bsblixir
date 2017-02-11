module Views exposing (..)

import Html exposing (div, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (href)
import Json.Encode
import Models exposing (Model, Story, Msg(..))


rawHtml : String -> Html.Attribute msg
rawHtml str =
    (Html.Attributes.property "innerHTML" (Json.Encode.string str))


controls : Model -> Html.Html Msg
controls model =
    div []
        [ Html.button [ onClick FetchStory ] [ text "load" ]
        , Html.br [] []
        , Html.input [] []
        , Html.button [] [ text "add" ]
        ]


storyDiv : Story -> Html.Html Msg
storyDiv story =
    div []
        [ Html.h2 []
            [ Html.a [ href story.url ] [ text story.title ]
            ]
        , Html.h4 [] [ text story.author ]
        , Html.p [] [ text story.summary ]
        , Html.p [ rawHtml story.content ] []
        ]


view : Model -> Html.Html Msg
view model =
    div []
        [ controls model
        , div [] <| List.map storyDiv model.stories
        ]
