defmodule BSB.StoryFetcher do
  def entry_to_story(entry) do
    %BSB.Story{
      author: entry.author,
      title: entry.title,
      subtitle: entry.subtitle,
      summary: entry.description,
      body: entry.content,
      url: entry.id,
      updated: Ecto.DateTime.utc()
    }
  end

  def feedparser_entry_to_story(entry) do
    %BSB.Story{
      author: entry.author,
      title: entry.title,
      summary: entry.description,
      body: entry.content,
      url: entry.id,
      updated: Ecto.DateTime.utc()
    }
  end

  def first_story_for_feed(url) do
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)
    #  {:ok, feed, _} = FeederEx.parse(body)
    feed = ElixirFeedParser.parse(body)

    feed.entries
    |> Enum.at(0)
    |> feedparser_entry_to_story
  end

end