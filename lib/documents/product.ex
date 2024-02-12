defmodule EaRestaurantDataLoader.Lib.Documents.Product do
    use Mongo.Collection

    collection "products" do
        attribute :name, String.t()
        attribute :description, String.t()
        attribute :entity_status, String.t()
        attribute :created_by, Integer.t()
        attribute :updated_by, Integer.t()
        attribute :created_date, DateTime.t()
        attribute :updated_date, DateTime.t()
    end
end
