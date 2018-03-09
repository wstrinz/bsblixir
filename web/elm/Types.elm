module Types exposing (..)

import Dict as D
import Http


type alias Story =
    { title : String
    , author : String
    , summary : String
    , content : String
    , updated : String
    , url : String
    , read : Bool
    , feedId : Int
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
    , base_score : Float
    , unreadCount : Int
    , decay_per_hour : Float
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
    , showDebug : Bool
    , currentView : View
    , currentFeed : Maybe Feed
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


type FeedUpdateField
    = BaseScore
    | DecayRate


type FeedUpdateValue
    = Float
    | String


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
    | UpdateFeedModel FeedUpdateField Feed String
    | UpdateFeed Feed
    | UpdateFeedResponse (Result Http.Error Feed)
    | OpenStory Story
    | SetStoryDisplayType StoryDisplayType
    | SetCurrentFeed (Maybe Feed)
    | SetShowDebug Bool
