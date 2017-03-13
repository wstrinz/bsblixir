module Models exposing (..)

import Http


type alias Story =
    { title : String
    , author : String
    , summary : String
    , content : String
    , updated : String
    , url : String
    , read : Bool
    , id : Int
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
    { stories : List Story, requestStatus : RequestStatus, feedToAdd : String, currentStory : Maybe Story, controlPanelVisible : Bool }


type Msg
    = Noop
    | LoadStory (Result Http.Error (List Story))
    | FetchStory
    | SetFeedToAdd String
    | AddFeed
    | AddFeedResponse (Result Http.Error Feed)
    | NextStory
    | PrevStory
    | UpdateStory Story
    | UpdateStoryResponse (Result Http.Error Story)
    | MarkStory Story
    | ToggleControlPanel
    | OpenStory Story


blankStory : Story
blankStory =
    { title = "A story", author = "Me", summary = "this is a summary", content = "this is some story content", url = "#", id = -1, updated = "", read = False }


errStory : a -> Story
errStory e =
    { title = "Something went wrong", summary = (toString e), author = "Me", content = (toString e), url = "", id = -2, updated = "", read = False }


storyForId : Int -> List Story -> Maybe Story
storyForId targetId storyList =
    List.head <| List.filter (\s -> s.id == targetId) storyList


nextOrHead : Maybe Story -> List Story -> Maybe Story
nextOrHead story storyList =
    case story of
        Just s ->
            findNext s.id storyList

        Nothing ->
            List.head storyList


findNext : Int -> List Story -> Maybe Story
findNext target currList =
    case currList of
        [] ->
            Nothing

        hd :: [] ->
            Nothing

        hd :: next :: tl ->
            if hd.id == target then
                Just next
            else
                findNext target <| next :: tl


initialModel : Model
initialModel =
    { stories = [ blankStory ]
    , requestStatus = { status = "init" }
    , feedToAdd = ""
    , currentStory = Nothing
    , controlPanelVisible = False
    }
