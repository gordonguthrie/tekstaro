defmodule Tekstaro.Tasks.ReleaseTasks do
  @start_apps [
    :postgrex,
    :ecto_sql
  ]

  @repo Tekstaro.Repo
  @otp_app :tekstaro

  def setup do
    boot()
    create_database()
    start_connection()
    run_migrations()
  end

  defp boot() do
    IO.puts("Booting pre-hook...")
    _ = Application.load(@otp_app)
    Enum.each(@start_apps, &Application.ensure_all_started/1)
  end

  defp create_database() do
    IO.puts("Creating the DB if needed")
    @repo.__adapter__.storage_up(@repo.config)
  end

  defp start_connection() do
    {:ok, _} = @repo.start_link(pool_size: 2)
  end

  defp run_migrations() do
    IO.puts("Running migrations")
    Ecto.Migrator.run(@repo, migrations_path(), :up, all: true)
  end

  defp migrations_path(), do: Path.join([priv_dir(), "repo", "migrations"])

  defp priv_dir(), do: "#{:code.priv_dir(@otp_app)}"

end
