defmodule EaRestaurantDataLoader.BaseFields do
    defmacro __using__(_opts) do
        quote do
            defstruct [:password, :encoded_password]
        end
    end
end
