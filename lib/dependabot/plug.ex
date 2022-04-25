defmodule Dependabot.Plug do
  use Plug.Builder

  plug Plug.Logger
  plug :auth
  plug :static
  plug :not_found

  defp auth(conn, _opts) do
    token = Application.fetch_env!(:dependabot, :auth_token)

    case get_req_header(conn, "authorization") do
      [^token] ->
        conn

      _ ->
        conn
        |> send_resp(401, "unknown or incorrect license key")
        |> halt()
    end
  end

  defp static(conn, _opts) do
    opts = Plug.Static.init(at: "/", from: "priv/registry")

    Plug.Static.call(conn, opts)
  end

  defp not_found(conn, _opts) do
    send_resp(conn, 404, "not found")
  end
end
