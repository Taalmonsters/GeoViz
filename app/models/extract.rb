class Extract < ActiveRecord::Base
  include NestedMetadata::Document
  include BlacklabRails::BlacklabDocument
  include SourceDocuments::Base
  
  def annotated_locs
    return self.get_group_entity_count("Annotations")
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
    self.metadatum_values.key("id").in_group("Annotations").where("content = ? OR content LIKE ? OR content LIKE ?", word_id, "%#{word_id}", "%#{word_id} %").first
  end
  
  protected
  
  def get_group_entity_count(group)
    NestedMetadata::MetadataGroup.has_name(group).first.entity_mentions.has_document(self).count
  end
  
end
