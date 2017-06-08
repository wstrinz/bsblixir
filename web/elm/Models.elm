module Models exposing (..)

import Http
import Dict as D


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


type alias StoryDict =
    D.Dict Int Story


type alias Model =
    { stories : StoryDict, requestStatus : RequestStatus, feedToAdd : String, currentStory : Maybe Story, controlPanelVisible : Bool }


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
    | SelectStory (Maybe Story)
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
            findNext story storyList

        Nothing ->
            List.head storyList


findNext : Maybe Story -> List Story -> Maybe Story
findNext target currList =
    case target of
        Nothing ->
            Nothing

        Just targetStory ->
            case currList of
                [] ->
                    Nothing

                hd :: [] ->
                    Nothing

                hd :: next :: tl ->
                    if hd.id == targetStory.id then
                        Just next
                    else
                        findNext target <| next :: tl


storyDictToList : StoryDict -> List Story
storyDictToList stories =
    List.reverse <| List.sortBy .updated <| List.map Tuple.second <| D.toList stories


storyListToDict : List Story -> StoryDict
storyListToDict stories =
    D.fromList <| List.map (\s -> ( s.id, s )) stories


initialModel : Model
initialModel =
    { stories = D.fromList []
    , requestStatus = { status = "init" }
    , feedToAdd = ""
    , currentStory = Nothing
    , controlPanelVisible = False
    }
