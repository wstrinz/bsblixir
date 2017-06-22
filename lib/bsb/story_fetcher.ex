defmodule BSB.StoryFetcher do
  def parsed_time(t) do
    case Timex.parse(t, "{RFC822}") do
      {:ok, parsed} -> parsed |> Ecto.DateTime.cast!
      {:error, _} -> nil
    end

  end

  def entry_to_story(entry) do
    %BSB.Story{
      author: entry.author,
      title: entry.title,
      subtitle: entry.subtitle,
      summary: entry.description,
      body: entry.content,
      url: entry.id,
      updated: parsed_time(entry.updated)
    }
  end

  def story_author(%{author: author}) do
    author
  end

  def story_author(%{authors: authors}) do
    authors |> Enum.join(", ")
  end

  def feedparser_entry_to_story(entry, feed) do
    %BSB.Story{
      author: story_author(entry),
      title: entry.title,
      summary: Map.get(entry, :description, ""),
      body: entry.content,
      url: entry.id,
      score: :rand.uniform(150) / 1,
      updated: entry.updated |> Ecto.DateTime.cast!,
      feed: feed
    }
  end

  # def first_story_for_feed(url) do
  #   get_entries_for(url)
  #   |> Enum.at(0)
  #   |> feedparser_entry_to_story
  # end

  def get_entries_for(feed_url) do
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(feed_url, [], follow_redirect: true)
    #  {:ok, feed, _} = FeederEx.parse(body)
    case ElixirFeedParser.parse(body) do
      {:ok, result} ->
        result.entries
      {:error, e} ->
        IO.puts("error parsing feed #{feed_url}")
        IO.inspect(e)
    end
  end

  def save_or_update_story(new_story) do
    curr_story =
      BSB.Story.story_for_url(new_story.url)
      |> Enum.at(0)

    if curr_story do
      %{new_story | id: curr_story.id}
      |> BSB.Story.changeset
      |> BSB.Repo.update!
    else
      BSB.Story.changeset(new_story)
      |> BSB.Repo.insert!
    end
  end

  def remove_invalids(stories) do
    {valid, invalid} = Enum.partition(stories, fn(ent) -> ent.updated != Nil end)
    if !Enum.empty?(invalid) do
      IO.puts("some invalid entries found!")
      IO.inspect(Enum.at(invalid, 0))
    end
    valid
  end

  def load_stories(feed) do
    get_entries_for(feed.url)
    |> Enum.map(fn(s) -> feedparser_entry_to_story(s, feed) end)
    |> remove_invalids
    |> Enum.map(&save_or_update_story/1)
  end

end
