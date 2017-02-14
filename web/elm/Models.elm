module Models exposing (..)

import Http


type alias Story =
    { title : String
    , author : String
    , summary : String
    , content : String
    , url : String
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
    { stories : List Story, requestStatus : RequestStatus, feedToAdd : String, currentStory : Int }


type Msg
    = Noop
    | LoadStory (Result Http.Error (List Story))
    | FetchStory
    | SetFeedToAdd String
    | AddFeed
    | AddFeedResponse (Result Http.Error Feed)
    | NextStory
    | PrevStory


blankStory : Story
blankStory =
    { title = "A story", author = "Me", summary = "this is a summary", content = "this is some story content", url = "#", id = -1 }


errStory : a -> Story
errStory e =
    { title = "Something went wrong", summary = "this is a summary", author = "Me", content = (toString e), url = "", id = -1 }


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


nextOrHead : Int -> List Story -> Int
nextOrHead target stories =
    let
        firstStory =
            List.head stories
    in
        case findNext target stories of
            Just s ->
                s.id

            Nothing ->
                case firstStory of
                    Just s ->
                        s.id

                    Nothing ->
                        -1


findNext : Int -> List Story -> Maybe Story
findNext target currList =
    let
        currItem =
            List.head currList

        t =
            List.tail currList

        rest =
            case t of
                Nothing ->
                    []

                Just r ->
                    r
    in
        case currItem of
            Nothing ->
                currItem

            Just li ->
                if li.id == target then
                    List.head <| rest
                else
                    findNext target rest


initialModel : Model
initialModel =
    { stories = [ blankStory ]
    , requestStatus = { status = "init" }
    , feedToAdd = ""
    , currentStory = 17
    }
