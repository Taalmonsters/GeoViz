Rails.application.routes.draw do
  mount Taalmonsters::Engine => "/"
  mount NestedMetadata::Engine => "/"
end
