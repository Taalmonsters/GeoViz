namespace :geoviz do
  
  namespace :import do
    
    desc "Import documents and metadata from GeoParser output"
    task geoparser: :environment do
      GeoViz::GeoParser::MetadataLoader.check_watchfolders
    end
    
  end
end
