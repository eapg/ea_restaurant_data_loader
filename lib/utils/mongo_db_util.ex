defmodule EaRestaurantDataLoader.Lib.Util.MongoDbUtil do

  def update_document_id_to_string(document) do
    %{_id: bson_object_id} = document
    {:ok, string_object_id} = BSON.ObjectId.encode(bson_object_id)
    Map.put(document, :_id, string_object_id)
  end
end

