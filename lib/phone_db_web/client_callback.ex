defmodule PhoneDbWeb.ClientCallback do
  @moduledoc """
  Implement OIDC client config
  """

  @behaviour OIDC.ClientConfig
  @impl true
  def get(_client_id) do
    config = Application.get_env(:phone_db, :oidc)

    %{
      "client_id" => config.client_id,
      "client_secret" => config.client_secret
    }
  end
end
