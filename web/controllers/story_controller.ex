defmodule BSB.StoryController do
  import Ecto.Query

  use BSB.Web, :controller
  alias BSB.Story

  defp story_selector(query, params) do
    if params["maxScore"] do
      query |> where([s], s.read == false and s.score <= ^params["maxScore"])
    else
      query |> where([s], s.read == false)
    end
  end

  def index(conn, params) do
    qry =
      from(
        s in Story,
        select: s,
        order_by: [desc: :score, desc: :updated],
        limit: 10
      )

    stories = qry |> story_selector(params) |> Repo.all()

    render(conn, "index.json", stories: stories)
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

    Repo.delete!(story)

    send_resp(conn, :no_content, "")
  end
end
