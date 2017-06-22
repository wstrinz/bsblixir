defmodule BSB.ScoreCalculator do
  alias BSB.Repo
  alias BSB.Feed
  alias BSB.Story
  import Ecto.Query, only: [from: 2]

  def calc_score_for_story(story) do
    # (from s in "stories",
    # where: s.feed_id
  end

  def recalculate_scores do
    Repo.all(Story)
  end
end
