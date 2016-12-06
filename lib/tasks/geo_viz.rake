namespace :geoviz do
  
  namespace :import do
    
    desc "Import documents and metadata from GeoParser output"
    task geoparser: :environment do
      GeoViz::GeoParser::MetadataLoader.check_watchfolders
    end
    
  end
  
  namespace :db do
    
    desc "Resets all tables except for the users table"
    task reset: :environment do
      [
        NestedMetadata::MetadataGroup,
        NestedMetadata::MetadataKey,
        NestedMetadata::MetadatumValue,
        NestedMetadata::BooleanValue,
        NestedMetadata::DateValue,
        NestedMetadata::FloatValue,
        NestedMetadata::IntegerValue,
        NestedMetadata::Location,
        NestedMetadata::StringValue,
        NestedMetadata::EntityMention,
        NestedMetadata::SourceDocument,
        Extract,
        Audited::Audit,
        SourceDocuments::DocumentLock
      ].each do |model|
        puts "Resetting #{model.name}"
        model.destroy_all
      end
    end
    
  end
end
