module Models exposing (..)

import Http


type alias Story =
    { title : String
    , author : String
    , summary : String
    , content : String
    , url : String
    }


type alias Feed =
    { title : String
    , description : String
    , url : String
    , feed_url : String
    , updated : String
    , id : Int
    }


type alias RequestStatus =
    { status : String }


type alias Model =
    { stories : List Story, requestStatus : RequestStatus, feedToAdd : String }


type Msg
    = Noop
    | LoadStory (Result Http.Error (List Story))
    | FetchStory
    | SetFeedToAdd String
    | AddFeed
    | AddFeedResponse (Result Http.Error Feed)


blankStory : Story
blankStory =
    { title = "A story", author = "Me", summary = "this is a summary", content = "this is some story content", url = "#" }


errStory : a -> Story
errStory e =
    { title = "Something went wrong", summary = "this is a summary", author = "Me", content = (toString e), url = "" }


initialModel : Model
initialModel =
    { stories = [ blankStory ]
    , requestStatus = { status = "init" }
    , feedToAdd = ""
    }
