defmodule PhoneDb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    # List all child processes to be supervised
    children = [
      {Cluster.Supervisor, [topologies, [name: PhoneDb.ClusterSupervisor]]},
      # Start the Ecto repository
      PhoneDb.Repo,
      # Start the endpoint when the application starts
      PhoneDbWeb.Endpoint,
      {Phoenix.PubSub, [name: PhoneDb.PubSub, adapter: Phoenix.PubSub.PG2]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoneDb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhoneDbWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
