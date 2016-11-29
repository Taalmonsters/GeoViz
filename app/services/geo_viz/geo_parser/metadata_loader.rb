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
        NestedMetadata::MetadataGroup.with_name("Annotations").first.update_attribute(:group_keys_into_entity, true)
        NestedMetadata::MetadataGroup.with_name("GeoParser").first.update_attribute(:group_keys_into_entity, true)
        metadata_group_id = NestedMetadata::MetadataGroup.with_name("GeoParser").first.id
        document_id = self.get_last_document_id
        source_document_id = self.get_last_source_document_id
        entity_mention_id = self.get_last_entity_mention_id
        Dir.entries(input_dir).select{|entry| !entry.start_with?('.') && entry.end_with?('.xml') && !entry.end_with?('.gaz.xml') }.each do |entry|
          file = "#{input_dir}/#{entry}"
          title = entry.sub(/\.xml$/,"")
          gaz_file = "#{input_dir}/#{title}.gaz.xml"
          generated_id = Digest::MD5.hexdigest(title)
          document_id += 1
          source_document_id += 1
          self.add_document(source_document_id, document_id, generated_id, title)
          self.set_blacklab_pid(document_id, title)
          main_xml_doc = Nokogiri::XML(File.read(file))
          xml_doc = Nokogiri::XML(File.read(gaz_file))
          xml_doc.css("placename").each do |placename|
            entity_mention_id += 1
            self.add_entity_mention_to_document(source_document_id, metadata_group_id, entity_mention_id, "location")
            place = placename.css("place").first
            self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["id"], self.get_placename_id(placename["id"], main_xml_doc)) if placename["id"]
            self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["name"], placename["name"]) if placename["name"]
            self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["latitude"], place["lat"].to_f) if place["lat"]
            self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["longitude"], place["long"].to_f) if place["long"]
            self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["population"], place["pop"].to_i) if place["pop"]
            if place["gazetteer"]
              self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["gazetteer"], place["gazetteer"])
              self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["gazref"], place["gazref"]) if place["gazref"]
            elsif place["gazref"]
              self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["gazetteer"], place["gazref"].split(":")[0])
              self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["gazref"], place["gazref"].split(":",2)[1])
            end
            self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["type"], place["type"]) if place["type"]
            self.add_metadatum_to_entity_mention(source_document_id, entity_mention_id, fields["GeoParser"]["country"], place["in-cc"]) if place["in-cc"]
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
    
    def self.get_placename_id(enamex_id, main_xml_doc)
      main_xml_doc.css("enamex[id=#{enamex_id}]")[0].css("w").map{|w| w["id"] }.join(" ")
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
