defmodule BSB.StoryControllerTest do
  use BSB.ConnCase

  alias BSB.Story
  alias BSB.Feed

  @fixture_url "feeds.feedburner.com/RockPaperShotgun"
  @valid_attrs %{
    author: "some content",
    subtitle: "some content",
    summary: "some content",
    title: "some content",
    updated: ~N[1990-03-05 00:10:50]
  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, story_path(conn, :index))
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    story = Repo.insert!(%Story{})
    conn = get(conn, story_path(conn, :show, story))

    assert json_response(conn, 200)["data"] == %{
             "id" => story.id,
             "author" => story.author,
             "title" => story.title,
             "subtitle" => story.subtitle,
             "read" => false,
             "body" => story.body,
             "url" => story.url,
             "summary" => story.summary,
             "updated" => story.updated,
             "score" => 0.0,
             "feedId" => nil
           }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, story_path(conn, :show, -1))
    end)
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    {:ok, feed} = Feed.add_feed(@fixture_url)
    story = Repo.insert!(%Story{feed: feed})
    conn = put(conn, story_path(conn, :update, story), story: @valid_attrs)
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Story, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    story = Repo.insert!(%Story{})
    conn = put(conn, story_path(conn, :update, story), story: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    story = Repo.insert!(%Story{})
    conn = delete(conn, story_path(conn, :delete, story))
    assert response(conn, 204)
    refute Repo.get(Story, story.id)
  end
end
