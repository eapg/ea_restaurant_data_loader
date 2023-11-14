defmodule EaRestaurantDataLoader.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias EaRestaurantDataLoader.Repo

      import Ecto
      import Ecto.Query
      import EaRestaurantDataLoader.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EaRestaurantDataLoader.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EaRestaurantDataLoader.Repo, {:shared, self()})
    end

    :ok
  end
end
