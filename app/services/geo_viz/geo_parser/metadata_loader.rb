require 'digest/md5'
require 'active_support/core_ext/hash/conversions'
module GeoViz
  class GeoParser::MetadataLoader < NestedMetadata::MetadataLoader
    
    def self.load_data
      root = Rails.root
      input_dir = root.join('data','new')
      output_dir = root.join('data','added')
      config = Rails.application.config
      fields = {}
      current_index = 0
      geoparser_keys = ["id", "name", "latitude", "longitude", "population", "gazetteer", "gazref", "type", "country"]
      ActiveRecord::Base.transaction do
        fields = self.add_groups_and_keys({ "Annotations" => geoparser_keys, "GeoParser" => geoparser_keys })
        NestedMetadata::MetadataGroup.with_name("GeoParser").first.update_attribute(:group_keys_into_entity, true)
        document_id = self.get_last_document_id
        Dir.entries(input_dir).select{|entry| !entry.start_with?('.') && entry.end_with?('.xml') && !entry.end_with?('.gaz.xml') }.each do |entry|
          file = "#{input_dir}/#{entry}"
          title = entry.sub(/\.xml$/,"")
          gaz_file = "#{input_dir}/#{title}.gaz.xml"
          generated_id = Digest::MD5.hexdigest(title)
          document_id += 1
          entity_count = 0
          self.add_document(document_id, generated_id, title)
          self.set_blacklab_pid(document_id, title)
          xml_doc = Nokogiri::XML(File.read(gaz_file))
          xml_doc.css("placename").each do |placename|
            entity_count += 1
            place = placename.css("place").first
            self.add_metadata_to_document(document_id, fields["GeoParser"]["id"], [placename["id"]], entity_count) if placename["id"]
            self.add_metadata_to_document(document_id, fields["GeoParser"]["name"], [placename["name"]], entity_count) if placename["name"]
            self.add_metadata_to_document(document_id, fields["GeoParser"]["latitude"], [place["lat"].to_f], entity_count) if place["lat"]
            self.add_metadata_to_document(document_id, fields["GeoParser"]["longitude"], [place["long"].to_f], entity_count) if place["long"]
            self.add_metadata_to_document(document_id, fields["GeoParser"]["population"], [place["pop"].to_i], entity_count) if place["pop"]
            if place["gazetteer"]
              self.add_metadata_to_document(document_id, fields["GeoParser"]["gazetteer"], [place["gazetteer"]], entity_count)
              self.add_metadata_to_document(document_id, fields["GeoParser"]["gazref"], [place["gazref"]], entity_count) if place["gazref"]
            elsif place["gazref"]
              self.add_metadata_to_document(document_id, fields["GeoParser"]["gazetteer"], [place["gazref"].split(":")[0]], entity_count)
              self.add_metadata_to_document(document_id, fields["GeoParser"]["gazref"], [place["gazref"]], entity_count)
            end
            self.add_metadata_to_document(document_id, fields["GeoParser"]["type"], [place["type"]], entity_count) if place["type"]
            self.add_metadata_to_document(document_id, fields["GeoParser"]["country"], [place["in-cc"]], entity_count) if place["in-cc"]
          end
          FileUtils.mv(file, "#{output_dir}/#{entry}")
          FileUtils.mv(gaz_file, "#{output_dir}/#{title}.gaz.xml")
        end
        fields.each do |group, metadata_keys|
          metadata_keys.each do |key, metadata_key|
            metadata_key.update_attribute(:preferred_value_type, self.get_preferred_value_type(key))
          end
        end
      end
      return {}
    end
    
    def self.get_preferred_value_type(key)
      return :float if ["latitude", "longitude"].include?(key)
      return :integer if ["population"].include?(key)
      return :string
    end
    
    def self.set_blacklab_pid(document_id, title)
      Extract.connection.execute "UPDATE #{Extract.table_name} SET blacklab_pid = '#{BlacklabRails::Blacklab.docs(nil,"HeadWord:#{title}")["docs"].first["docPid"]}' WHERE id = #{document_id};"
    end
    
  end
end
