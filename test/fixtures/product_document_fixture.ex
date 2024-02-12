defmodule EaRestaurantDataLoader.Test.Fixtures.ProductDocumentFixture do
  def build_product(name) do
    %{
      "name" => name,
      "description"=> "Test Product",
      "entity_status"=> "ACTIVE",
      "created_by"=> 1,
      "updated_by"=> 1,
      "created_date"=> DateTime.utc_now(),
      "updated_date"=> DateTime.utc_now()
    }
  end
end
