defmodule ConnectFourBackendWeb.PageController do
  use ConnectFourBackendWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
