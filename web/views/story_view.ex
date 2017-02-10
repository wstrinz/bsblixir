defmodule BSB.StoryView do
  use BSB.Web, :view

  def render("index.json", %{stories: stories}) do
    %{data: render_many(stories, BSB.StoryView, "story.json")}
  end

  def render("show.json", %{story: story}) do
    %{data: render_one(story, BSB.StoryView, "story.json")}
  end

  def render("story.json", %{story: story}) do
    %{id: story.id,
      author: story.author,
      title: story.title,
      subtitle: story.subtitle,
      summary: story.summary,
      url: story.url,
      updated: story.updated}
  end
end
