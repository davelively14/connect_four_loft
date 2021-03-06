defmodule ConnectFourBackend.Repo do
  use Ecto.Repo, otp_app: :connect_four_backend

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
