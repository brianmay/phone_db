defmodule PhoneDbWeb.LayoutView do
  use PhoneDbWeb, :html

  @spec prepend_if(list :: list(), condition :: bool(), item :: any()) :: list()
  def prepend_if(list, condition, item) do
    if condition, do: [item | list], else: list
  end

  def link_class(active, item) do
    ["nav-link"]
    |> prepend_if(active == item, "active")
    |> Enum.join(" ")
  end
end
