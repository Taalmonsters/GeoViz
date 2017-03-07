require 'digest/md5'
require 'active_support/core_ext/hash/conversions'
module GeoViz
  class GeoParser::MetadataLoader < NestedMetadata::MetadataLoader

    def self.extract_historical_coordinates
      group = NestedMetadata::MetadataGroup.where("name = ?", "Metadata").first || self.add_group("Metadata")
      lat_key = group.metadata_keys.where("name = ?", "historical latitude").first || self.add_key_to_group(group, "historical latitude")
      lat_docs = {}
      resp = BlacklabRails::Blacklab.hits({
        :patt => '[word="lat|latit|latitude"][pos="PUNC"]{0,1}([word="[0-9]+"][pos="PUNC"]{0,1}){1,}',
        :number => 15000
      })
      resp["hits"].each do |hit|
        docPid = hit["docPid"]
        match = hit["match"]["word"]
        if !lat_docs.has_key?(docPid) || match.length > lat_docs[docPid].length
          lat_docs[docPid] = match
        end
      end
      lat_docs.each do |docPid, match|
        extract = Extract.where(:blacklab_pid => docPid).first
        if extract
          extract.source_document.metadatum_values.has_key(lat_key).has_content(match.select{|m| m =~ /^[0-9]+$/ }.join(".")).first_or_create
        else
          puts "WARNING: Could not find Extract with blacklab_pid #{docPid}."
        end
      end
      lng_key = group.metadata_keys.where("name = ?", "historical longitude").first || self.add_key_to_group(group, "historical longitude")
      lng_docs = {}
      resp = BlacklabRails::Blacklab.hits({
        :patt => '[word="Lon|Long|Longit|Longitude"][pos="PUNC"]{0,1}([word="[0-9]+"][pos="PUNC"]{0,1}){1,}',
        :number => 15000
      })
      resp["hits"].each do |hit|
        docPid = hit["docPid"]
        match = hit["match"]["word"]
        if !lng_docs.has_key?(docPid) || match.length > lng_docs[docPid].length
          lng_docs[docPid] = match
        end
      end
      lng_docs.each do |docPid, match|
        extract = Extract.where(:blacklab_pid => docPid).first
        if extract
          extract.source_document.metadatum_values.has_key(lng_key).has_content(match.select{|m| m =~ /^[0-9]+$/ }.join(".")).first_or_create
        else
          puts "WARNING: Could not find Extract with blacklab_pid #{docPid}."
        end
      end
    end

    def self.mark_for_annotation
      groups = NestedMetadata::MetadataGroup.where("name = ?", "Metadata")
      group = groups.any? ? groups.first : self.add_group("Metadata")
      keys = group.metadata_keys.where("name = ?", "gold standard")
      key = keys.any? ? keys.first : self.add_key_to_group(group, "gold standard")
      Extract.where("token_count > 50").shuffle(random: Random.new(Rails.application.config.seed)).take(100).each do |extract|
        extract.source_document.metadatum_values.has_key(key).has_content("true").first_or_create
      end
    end
    
    def self.load_data
      root = Rails.root
      input_dir = root.join('data','new')
      output_dir = root.join('data','added')
      config = Rails.application.config
      fields = {}
      current_index = 0
      geoparser_keys = ["id", "name", "latitude", "longitude", "population", "gazetteer", "gazref", "type", "country"]
      annotation_keys = geoparser_keys + ["location type", "remarks", "part of name", "is main location", "near main location", "position wrt main"]
      ActiveRecord::Base.transaction do
        fields = self.add_groups_and_keys({ "Annotations" => annotation_keys, "GeoParser" => geoparser_keys })
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
          self.set_blacklab_pid_and_token_count(document_id, title)
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
#        fields.each do |group, metadata_keys|
#          metadata_keys.each do |key, metadata_key|
#            metadata_key.update_attribute(:preferred_value_type, self.get_preferred_value_type(key))
#          end
#        end
      end
      return fields
    end
    
    def self.get_placename_id(enamex_id, main_xml_doc)
      main_xml_doc.css("enamex[id=#{enamex_id}]")[0].css("w").map{|w| w["id"] }.join(" ")
    end
    
    def self.get_preferred_value_type(key)
      return :float if ["latitude", "longitude"].include?(key)
      return :integer if ["population"].include?(key)
      return :string
    end
    
    def self.set_blacklab_pid_and_token_count(document_id, title)
      t = title.gsub(/é/,'e%CC%81').gsub(/É/,'E%CC%81').gsub(/ç/,'c%CC%A7')
      blacklab_documents = BlacklabRails::Blacklab.docs({ :filter => "HeadWord:#{t}" })["docs"]
      blacklab_document = blacklab_documents.length == 1 ? blacklab_documents.first : blacklab_documents.select{|doc| doc["docInfo"]["HeadWord"].eql?(title) || I18n.transliterate(doc["docInfo"]["HeadWord"]).gsub('?','').eql?(I18n.transliterate(title)) }.first
      unless blacklab_document
        STDOUT.puts "Warning: Could not find blacklab document for head word '#{title}'"
        if blacklab_documents.any?
          STDOUT.puts "Documents found:"
          blacklab_documents.each do |doc|
            STDOUT.puts "#{doc["docPid"]}: #{doc["docInfo"]["HeadWord"]}"
          end
        end
        STDOUT.puts "What is the pid of the correct blacklab document? "
        pid = STDIN.gets.strip
        STDOUT.puts "You selected pid #{pid}"
        blacklab_document = BlacklabRails::Blacklab.doc(pid)
      end
      Extract.connection.execute "UPDATE #{Extract.table_name} SET blacklab_pid = '#{blacklab_document["docPid"]}' WHERE id = #{document_id};"
      Extract.connection.execute "UPDATE #{Extract.table_name} SET token_count = #{blacklab_document["docInfo"]["lengthInTokens"]} WHERE id = #{document_id};"
    end
    
  end
end
