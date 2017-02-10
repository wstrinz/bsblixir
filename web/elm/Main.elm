module Main exposing (..)

import Html exposing (div, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (href)
import Http
import Json.Decode as Json
import Json.Decode.Pipeline exposing (decode, required, requiredAt, optional, hardcoded)


type alias Story =
    { title : String, author : String, content : String, url : String }


type alias Model =
    { stories : List Story }


type Msg
    = Noop
    | LoadStory (Result Http.Error (List Story))
    | FetchStory


blankStory : Story
blankStory =
    { title = "A story", author = "Me", content = "this is some story content", url = "#" }


errStory : a -> Story
errStory e =
    { title = "Something went wrong", author = "Me", content = (toString e), url = "" }


initialModel : Model
initialModel =
    { stories =
        [ blankStory
        ]
    }


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


getStory : Cmd Msg
getStory =
    let
        storyUrl =
            "/stories"

        req =
            Http.get storyUrl storyListDecorder
    in
        Http.send LoadStory req


storyDecoder : Json.Decoder Story
storyDecoder =
    decode Story
        |> required "title" Json.string
        |> required "author" Json.string
        |> required "summary" Json.string
        |> required "url" Json.string


storyListDecorder : Json.Decoder (List Story)
storyListDecorder =
    Json.at [ "data" ] (Json.list storyDecoder)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchStory ->
            ( model, getStory )

        LoadStory (Ok storyData) ->
            ( { model | stories = storyData }
            , Cmd.none
            )

        LoadStory (Err e) ->
            ( { model | stories = [ errStory e ] }, Cmd.none )

        _ ->
            ( model, Cmd.none )


storyDiv : Story -> Html.Html Msg
storyDiv story =
    div []
        [ Html.h2 []
            [ Html.a [ href story.url ] [ text story.title ]
            ]
        , Html.h4 [] [ text story.author ]
        , Html.p [] [ text story.content ]
        , Html.button [ onClick FetchStory ] [ text "load" ]
        ]


view : Model -> Html.Html Msg
view model =
    div [] <| List.map storyDiv model.stories
