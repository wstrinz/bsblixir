defmodule BSB.PageControllerTest do
  use BSB.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ ~s[<div id="elm-main"></div>]
  end
end
