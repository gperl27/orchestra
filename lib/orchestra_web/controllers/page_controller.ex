defmodule OrchestraWeb.PageController do
  use OrchestraWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
