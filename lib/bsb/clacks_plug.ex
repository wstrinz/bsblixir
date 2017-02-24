defmodule BSB.ClacksPlug do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    put_resp_header(conn, "x-clacks-overhead", "GNU Terry Pratchett")
  end
end