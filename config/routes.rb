Rails.application.routes.draw do
  mount Taalmonsters::Engine => "/"
  mount NestedMetadata::Engine => "/"
  
  get "/extracts/sources/:source_document_id/metadata_groups/:metadata_group_id/entity_mentions/:id" => "geo_viz/entity_mentions#edit"
  delete "/extracts/sources/:source_document_id/metadata_groups/:metadata_group_id/entity_mentions/:id" => "geo_viz/entity_mentions#destroy"
  get "/placenames/geocode" => "geo_viz/placenames#geocode"
  
  get "/map" => "taalmonsters/visitors#locations"
end
