require 'digest/md5'
module NestedMetadata
  class WhitelabCondensed::MetadataLoader < NestedMetadata::MetadataLoader
    
    def self.load_data
      root = Rails.root
      input_dir = root.join('data','new')
      config = Rails.application.config
      fields = {}
      current_index = 0
      geoparser_keys = ["id", "name", "latitude", "longitude", "population", "gazetteer", "gazref", "type", "country"]
      ActiveRecord::Base.transaction do
        fields = self.add_groups_and_keys({ "GeoParser" => geoparser_keys })
        NestedMetadata::MetadataGroup.with_name("GeoParser").first.update_attribute(:group_keys_into_entity, true)
        document_id = self.get_last_document_id
        Dir.entries(input_dir).select{|entry| !entry.start_with?('.') && entry.end_with?('.xml') && !entry.end_with?('.gaz.xml') }.each do |entry|
          file = "#{input_dir}/#{entry}"
          title = entry.sub(/\.xml$/,"")
          gaz_file = "#{input_dir}/#{title}.gaz.xml"
          generated_id = Digest::MD5.hexdigest(title)
          document_id += 1
          self.add_document(document_id, generated_id, title)
          xml_doc = Nokogiri::XML(File.read(gaz_file))
          xml_doc.css("placename").each do |placename|
            place = placename.css("place").first
            self.add_metadata_to_document(document_id, fields["GeoParser"]["id"], [placename["id"]]) if placename.has_key?("id")
            self.add_metadata_to_document(document_id, fields["GeoParser"]["name"], [placename["name"]]) if placename.has_key?("name")
            self.add_metadata_to_document(document_id, fields["GeoParser"]["latitude"], [place["lat"].to_f]) if place.has_key?("lat")
            self.add_metadata_to_document(document_id, fields["GeoParser"]["longitude"], [place["long"].to_f]) if place.has_key?("long")
            self.add_metadata_to_document(document_id, fields["GeoParser"]["population"], [place["pop"].to_i]) if place.has_key?("pop")
            if place.has_key?("gazetteer")
              self.add_metadata_to_document(document_id, fields["GeoParser"]["gazetteer"], [place["gazetteer"]])
              self.add_metadata_to_document(document_id, fields["GeoParser"]["gazref"], [place["gazref"]]) if place.has_key?("gazref")
            elsif place.has_key?("gazref")
              self.add_metadata_to_document(document_id, fields["GeoParser"]["gazetteer"], [place["gazref"].split(":")[0]])
              self.add_metadata_to_document(document_id, fields["GeoParser"]["gazref"], [place["gazref"]])
            end
            self.add_metadata_to_document(document_id, fields["GeoParser"]["type"], [place["type"]]) if place.has_key?("type")
            self.add_metadata_to_document(document_id, fields["GeoParser"]["country"], [place["in-cc"]]) if place.has_key?("in-cc")
          end
        end
      end
      return fields
    end
    
  end
end
