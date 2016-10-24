defmodule Rumbl.SessionController do
  use Rumbl.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case Rumbl.Auth.login_by_username_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} -> conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: page_path(conn, :index))
      {:error, :unauthorized, conn} ->
        conn |> render_login_error("Invalid password")
      {:error, :not_found, conn} ->
        conn |> render_login_error("That user doesn't exist")
      {:error, _reason, conn} ->
        conn |> render_login_error("An unknown error occurred")
    end
  end

  def delete(conn, _) do
    conn
    |> Rumbl.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end

  defp render_login_error(conn, message) do
    conn
    |> put_flash(:error, message)
    |> render("new.html")
  end
end
