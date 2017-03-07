namespace :geoviz do

  namespace :extracts do

    desc "Mark GS documents for annotation"
    task gold_standard: :environment do
      puts "Marking documents for gold standard annotation..."
      GeoViz::GeoParser::MetadataLoader.mark_for_annotation
    end

    desc "Extract historical latitude and longitude from the document content"
    task historical: :environment do
      puts "Extracting historical coordinates..."
      GeoViz::GeoParser::MetadataLoader.extract_historical_coordinates
    end

  end

  
  namespace :import do
    
    desc "Import documents and metadata from GeoParser output"
    task geoparser: :environment do
      puts "Importing documents..."
      GeoViz::GeoParser::MetadataLoader.check_watchfolders
    end
    
  end
  
  namespace :db do
    
    desc "Resets all tables except for the users table and move all imported files back to /data/new"
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
      root = Rails.application.root
      Dir.entries(root.join("data","added")).select{|entry| !entry.start_with?('.') }.each do |entry|
        File.rename "#{root.join("data", "added")}/#{entry}", "#{root.join("data", "new")}/#{entry}"
      end
    end
    
  end
end
