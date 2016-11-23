Rails.application.routes.draw do
  mount Taalmonsters::Engine => "/"
  mount NestedMetadata::Engine => "/"
  
  get "/documents/:id/entities/:entity_id" => "geo_viz/documents#entity"
  get "/documents/:id/placenames/geocode" => "geo_viz/placenames#geocode"
end
