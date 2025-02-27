defmodule PhoneDbWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use PhoneDbWeb, :controller
      use PhoneDbWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """
  def static_paths, do: ~w(css js fonts images favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller, namespace: PhoneDbWeb

      import Plug.Conn
      use Gettext, backend: PhoneDbWeb.Gettext
      alias PhoneDbWeb.Router.Helpers, as: Routes

      unquote(verified_routes())
    end
  end

  def html do
    quote do
      use Phoenix.View,
        root: "lib/phone_db_web/templates",
        namespace: PhoneDbWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  @spec live_view :: {:__block__, [], [{:__block__, [], [...]} | {:use, [...], [...]}, ...]}
  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {PhoneDbWeb.LayoutView, :live}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      use Gettext, backend: PhoneDbWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View
      import Phoenix.Component

      import PhoneDbWeb.ErrorHelpers
      use Gettext, backend: PhoneDbWeb.Gettext
      alias PhoneDbWeb.Router.Helpers, as: Routes

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: PhoneDbWeb.Endpoint,
        router: PhoneDbWeb.Router,
        statics: PhoneDbWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
