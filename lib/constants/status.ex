defmodule EaRestaurantDataLoader.Status do
  @values %{active: "ACTIVE", deleted: "DELETED"}

  def get_values, do: @values

  def active do
    %{active: active} = get_values()
    active
  end

  def deleted do
    %{deleted: deleted} = get_values()
    deleted
  end
end
