class Extract < ActiveRecord::Base
  include NestedMetadata::Document
  include BlacklabRails::BlacklabDocument
  include SourceDocuments::Base
  
  def annotated_locs
    return self.get_group_entity_count("Annotations")
  end
  
  def annotated_word_ids
    id_key = NestedMetadata::MetadataGroup.has_name("Annotations").first.metadata_keys.has_name("id").first
    self.source_document.entity_mentions.has_group_name("Annotations").with_value_for_key(id_key, "word_id").uniq.map{|entity_mention| [entity_mention.word_id, entity_mention.id] }.to_h
  end
  
  def geoparser_locs
    return self.get_group_entity_count("GeoParser")
  end
  
  def get_map(groups = [])
    map = Taalmonsters::Maps::Google::SimpleMap.new
    groups.each do |group|
      results = self.metadatum_values.in_group(group).by_entity
      results.each do |entity_id, values|
        marker = Taalmonsters::Maps::Google::SimpleMapMarker.new
        marker.set_coordinates(values.select{|mv| mv.metadata_key.name.eql?("latitude") }.first.value.content,values.select{|mv| mv.metadata_key.name.eql?("longitude") }.first.value.content)
        marker.label = values.select{|mv| mv.metadata_key.name.eql?("name") }.first.value.content
        marker.letter = marker.label[0]
        marker.color = "98598E"
        marker.infowindow = "<div>#{marker.label}</div>"
        map.add_marker(marker)
      end
    end
    return map
  end
  
  def word_annotated(word_id)
    id_key = NestedMetadata::MetadataGroup.has_name("Annotations").first.metadata_keys.has_name("id").first
    self.source_document.entity_mentions.has_group_name("Annotations").with_metadatum_values.select("(SELECT mv1.content FROM #{NestedMetadata::MetadatumValue.table_name} AS mv1 WHERE mv1.metadata_key_id = #{id_key.id} AND mv1.entity_mention_id = #{NestedMetadata::EntityMention.table_name}.id) AS word_id, #{NestedMetadata::EntityMention.table_name}.*").all.select{|em| em.word_id =~ / *#{word_id} / || em.word_id =~ / *#{word_id}$/ }.first
  end
  
  protected
  
  def get_group_entity_count(group)
    self.source_document.entity_mentions.has_group_name(group).count
    # NestedMetadata::MetadataGroup.has_name(group).first.entity_mentions.has_document(self).count
  end
  
end
