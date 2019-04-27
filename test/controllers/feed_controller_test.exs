defmodule BSB.FeedControllerTest do
  use BSB.ConnCase

  alias BSB.Feed
  @fixture_url "feeds.feedburner.com/RockPaperShotgun"
  @valid_attrs %{url: @fixture_url}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, feed_path(conn, :index))
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    feed = Repo.insert!(%Feed{})
    conn = get(conn, feed_path(conn, :show, feed))

    assert json_response(conn, 200)["data"] == %{
             "id" => feed.id,
             "title" => feed.title,
             "description" => feed.description,
             "url" => feed.url,
             "feed_url" => feed.feed_url,
             "updated" => feed.updated,
             "base_score" => 0.0,
             "decay_per_hour" => 1 / 96,
             "unreadCount" => 0,
             "error" => feed.error
           }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, feed_path(conn, :show, -1))
    end)
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post(conn, feed_path(conn, :create), @valid_attrs)
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Feed, feed_url: @fixture_url)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    assert catch_error(post(conn, feed_path(conn, :create), feed: @invalid_attrs))
    # assert json_response(conn, 422)["errors"] != %{}
  end

  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   feed = Repo.insert! %Feed{}
  #   conn = put conn, feed_path(conn, :update, feed), feed: @valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(Feed, @valid_attrs)
  # end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    feed = Repo.insert!(%Feed{})
    conn = put(conn, feed_path(conn, :update, feed), feed: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    feed = Repo.insert!(%Feed{})
    conn = delete(conn, feed_path(conn, :delete, feed))
    assert response(conn, 204)
    refute Repo.get(Feed, feed.id)
  end
end
