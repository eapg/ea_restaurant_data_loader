defmodule EaRestaurantDataLoader.Lib.Constants.HttpStatus do
    @values ["OK"]
  
    def get_values, do: @values
  
    def ok, do: get_values() |> Enum.at(0)
  end


