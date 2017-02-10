defmodule BSB.StoryController do
  use BSB.Web, :controller

  alias BSB.Story

  def index(conn, _params) do
    stories = Repo.all(Story)
    render(conn, "index.json", stories: stories)
  end

  def create(conn, %{"story" => story_params}) do
    changeset = Story.changeset(%Story{}, story_params)

    case Repo.insert(changeset) do
      {:ok, story} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", story_path(conn, :show, story))
        |> render("show.json", story: story)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BSB.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    story = Repo.get!(Story, id)
    render(conn, "show.json", story: story)
  end

  def update(conn, %{"id" => id, "story" => story_params}) do
    story = Repo.get!(Story, id)
    changeset = Story.changeset(story, story_params)

    case Repo.update(changeset) do
      {:ok, story} ->
        render(conn, "show.json", story: story)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BSB.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    story = Repo.get!(Story, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(story)

    send_resp(conn, :no_content, "")
  end
end
