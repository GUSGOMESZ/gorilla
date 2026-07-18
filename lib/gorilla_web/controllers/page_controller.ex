defmodule GorillaWeb.PageController do
  use GorillaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
