Rails.application.routes.draw do
  mount Taalmonsters::Engine => "/"
  mount NestedMetadata::Engine => "/"
  
  get "/placenames/geocode" => "geo_viz/placenames#geocode"
end
