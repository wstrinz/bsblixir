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
    { stories : List Story, requestStatus : RequestStatus, feedToAdd : String, currentStory : Int, controlPanelVisible : Bool }


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


currStory : Model -> Story
currStory model =
    let
        matched =
            List.head <| List.filter (\s -> model.currentStory == s.id) model.stories
    in
        case matched of
            Just s ->
                s

            Nothing ->
                errStory "couldn't find currentStory"


storyForId : Int -> List Story -> Maybe Story
storyForId targetId storyList =
    List.head <| List.filter (\s -> s.id == targetId) storyList


nextOrHead : Int -> List Story -> Int
nextOrHead id storyList =
    case Maybe.map .id <| findNext id storyList of
        Just i ->
            i

        Nothing ->
            case List.head storyList of
                Just li ->
                    li.id

                Nothing ->
                    -1


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
    , currentStory = 17
    , controlPanelVisible = False
    }
