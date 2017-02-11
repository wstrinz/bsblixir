module Models exposing (..)

import Http


type alias Story =
    { title : String, author : String, summary : String, content : String, url : String }


type alias Model =
    { stories : List Story }


type Msg
    = Noop
    | LoadStory (Result Http.Error (List Story))
    | FetchStory


blankStory : Story
blankStory =
    { title = "A story", author = "Me", summary = "this is a summary", content = "this is some story content", url = "#" }


errStory : a -> Story
errStory e =
    { title = "Something went wrong", summary = "this is a summary", author = "Me", content = (toString e), url = "" }


initialModel : Model
initialModel =
    { stories =
        [ blankStory
        ]
    }
