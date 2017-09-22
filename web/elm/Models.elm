module Models exposing (..)

import Http
import Dict as D
import List.Extra exposing (dropWhile)
import Maybe exposing (withDefault)


type alias Story =
    { title : String
    , author : String
    , summary : String
    , content : String
    , updated : String
    , url : String
    , read : Bool
    , score : Float
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


type alias FeedDict =
    D.Dict Int Feed


type alias Model =
    { stories : StoryDict
    , requestStatus : RequestStatus
    , feedToAdd : String
    , currentStory : Maybe Story
    , controlPanelVisible : Bool
    , currentView : View
    , feeds : FeedDict
    , storyDisplayType : StoryDisplayType
    }


type View
    = StoryView
    | FeedView Feed
    | FeedsView


type StoryDisplayType
    = Full
    | Titles


type Msg
    = Noop
    | FetchStory
    | LoadStory (Result Http.Error (List Story))
    | FetchFeeds
    | LoadFeeds (Result Http.Error (List Feed))
    | SetFeedToAdd String
    | AddFeed
    | AddFeedResponse (Result Http.Error Feed)
    | NextStory
    | PrevStory
    | UpdateStory Bool Story
    | UpdateStoryResponse Bool (Result Http.Error Story)
    | MarkStory Story
    | ToggleControlPanel
    | SetView View
    | SelectStory (Maybe Story)
    | OpenStory Story
    | SetStoryDisplayType StoryDisplayType
    | SetCurrentFeed Feed


blankStory : Story
blankStory =
    { title = "A story", author = "Me", summary = "this is a summary", content = "this is some story content", url = "#", id = -1, updated = "", read = False, score = 0 }


errStory : a -> Story
errStory e =
    { title = "Something went wrong", summary = (toString e), author = "Me", content = (toString e), url = "", id = -2, updated = "", read = False, score = 0 }


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


findRest : Maybe Story -> List Story -> List Story
findRest target currList =
    case target of
        Just targetStory ->
            currList
                |> dropWhile (\s -> not <| s.id == targetStory.id)
                |> List.tail
                |> withDefault []

        Nothing ->
            []


storySort : Story -> Story -> Order
storySort a b =
    case compare a.score b.score of
        GT ->
            GT

        LT ->
            LT

        EQ ->
            compare a.id b.id


storyDictToList : StoryDict -> List Story
storyDictToList stories =
    List.reverse <| List.sortWith storySort <| List.map Tuple.second <| D.toList stories


storyListToDict : List Story -> StoryDict
storyListToDict stories =
    D.fromList <| List.map (\s -> ( s.id, s )) stories


feedListToDict : List Feed -> FeedDict
feedListToDict stories =
    D.fromList <| List.map (\s -> ( s.id, s )) stories


initialModel : Model
initialModel =
    { stories = D.fromList []
    , feeds = D.fromList []
    , requestStatus = { status = "init" }
    , feedToAdd = ""
    , currentStory = Nothing
    , currentView = FeedsView
    , controlPanelVisible = False
    , storyDisplayType = Full
    }
