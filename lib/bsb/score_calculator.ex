defmodule BSB.ScoreCalculator do
  alias BSB.Repo
  alias BSB.Feed
  alias BSB.Story
  import Ecto.Query, only: [from: 2]

  def calc_score_for_story(story, feed) do
    converted_time =
      story.updated
      |> Ecto.DateTime.cast!
      |> Ecto.DateTime.dump
      |> elem(1)
      |> Timex.DateTime.Helpers.construct("Etc/UTC")

    hrs_ago =
      Timex.diff(Timex.now(), converted_time, :hours)

    feed.base_score * :math.pow(1 - feed.decay_per_hour, hrs_ago)
    |> Float.round(2)
  end

  defp story_change_score(new_score, story) do
    Story.changeset(story, %{score: new_score})
  end

  def recalculate_scores do
      Repo.all(from s in Story, preload: [:feed])
      |> Enum.map(fn(s) -> s
         |> calc_score_for_story(s.feed)
         |> story_change_score(s)
         |> Repo.update!
       end)
  end


end
