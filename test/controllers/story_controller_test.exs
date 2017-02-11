defmodule BSB.StoryControllerTest do
  use BSB.ConnCase

  alias BSB.Story
  @valid_attrs %{author: "some content", subtitle: "some content", summary: "some content", title: "some content", updated: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, story_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    story = Repo.insert! %Story{}
    conn = get conn, story_path(conn, :show, story)
    assert json_response(conn, 200)["data"] == %{"id" => story.id,
      "author" => story.author,
      "title" => story.title,
      "subtitle" => story.subtitle,
      "body" => story.body,
      "url" => story.url,
      "summary" => story.summary,
      "updated" => story.updated}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, story_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, story_path(conn, :create), story: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Story, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, story_path(conn, :create), story: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    story = Repo.insert! %Story{}
    conn = put conn, story_path(conn, :update, story), story: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Story, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    story = Repo.insert! %Story{}
    conn = put conn, story_path(conn, :update, story), story: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    story = Repo.insert! %Story{}
    conn = delete conn, story_path(conn, :delete, story)
    assert response(conn, 204)
    refute Repo.get(Story, story.id)
  end
end
