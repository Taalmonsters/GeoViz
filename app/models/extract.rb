class Extract < ActiveRecord::Base
  include NestedMetadata::Document
  include BlacklabRails::BlacklabDocument
  include SourceDocuments::Base
  
  scope :grouped_locations, -> { locations.values.flatten
    .select{|entity_mention| entity_mention.latitude && entity_mention.latitude.content && entity_mention.longitude && entity_mention.longitude.content }
    .group_by{|entity_mention| [entity_mention.latitude.content.to_f, entity_mention.longitude.content.to_f] } }
  scope :locations, -> { with_locations.map{|extract| [extract,extract.entity_mentions] }.to_h }
  scope :user_locations, -> user_id { with_locations.map{|extract| [extract,extract.entity_mentions.select{|entity_mention| entity_mention.audits.where("user_id = ?", user_id).any? }] }.to_h }
  scope :with_locations, -> { includes(:entity_mentions).merge(NestedMetadata::EntityMention.as_locations) }
  
  scope :token_count_in_range, -> boundary { where("token_count >= ? AND token_count <= ?", boundary[0], boundary[1]) }
  scope :annotated_by_user, -> user_id { joins(:entity_mentions => [:audits]).where("audits.user_id = ?", Extract.get_user_id(user_id[0])) }
  scope :grouped_by_annotator, -> { joins(:entity_mentions => [:audits]).group("audits.user_id") }
  
  def annotated_locs(user_id)
    return self.get_group_entity_count("Annotations", user_id)
  end

  def annotated_locs_total
    return self.get_group_entity_count("Annotations")
  end
  
  def annotated_word_ids(user_id)
    id_key = NestedMetadata::MetadataGroup.has_name("Annotations").first.metadata_keys.has_name("id").first
    return self.source_document.entity_mentions.has_group_name("Annotations").with_value_for_key(id_key, "word_id").uniq
        .select{|entity_mention| entity_mention.audits.where("user_id = ?", user_id).any? }
        .map{|entity_mention| [entity_mention.word_id, entity_mention.id] }.to_h
  end

  def geoparser_word_ids
    id_key = NestedMetadata::MetadataGroup.has_name("GeoParser").first.metadata_keys.has_name("id").first
    return self.source_document.entity_mentions.has_group_name("GeoParser").with_value_for_key(id_key, "word_id").uniq
        .map{|entity_mention| [entity_mention.word_id, entity_mention.id] }.to_h
  end
  
  def geoparser_locs
    return self.get_group_entity_count("GeoParser")
  end
  
  def grouped_locations
    self.locations.select{|entity_mention| entity_mention.latitude && entity_mention.latitude.content && entity_mention.longitude && entity_mention.longitude.content }
    .group_by{|entity_mention| [entity_mention.latitude.content.to_f, entity_mention.longitude.content.to_f] }
  end

  def historical_latitude
    mv = self.source_document.metadatum_values.has_key(NestedMetadata::MetadataKey.in_group("Metadata").with_name("historical latitude").first).first
    return mv ? mv.value.content : nil
  end

  def historical_longitude
    mv = self.source_document.metadatum_values.has_key(NestedMetadata::MetadataKey.in_group("Metadata").with_name("historical longitude").first).first
    return mv ? mv.value.content : nil
  end
  
  def locations
    self.source_document.entity_mentions.as_locations
  end

  def unattached_annotations(user_id)
    id_key = NestedMetadata::MetadataGroup.has_name("Annotations").first.metadata_keys.has_name("id").first
    data = self.source_document.entity_mentions.has_group_name("Annotations").with_value_for_key(id_key, "word_id").uniq
                   .select{|entity_mention| entity_mention.audits.where("user_id = ?", user_id).any? }
                   .map{|entity_mention| entity_mention.id }.uniq.sort
    puts data.to_json
    return data
  end

  def user_locations(group, user_id)
    self.source_document.entity_mentions.as_locations.has_group_name(group).select{|entity_mention| entity_mention.audits.where("user_id = ?", user_id).any? }
  end
  
  def word_annotated(word_id)
    id_key = NestedMetadata::MetadataGroup.has_name("Annotations").first.metadata_keys.has_name("id").first
    self.source_document.entity_mentions.has_group_name("Annotations").with_metadatum_values.select("(SELECT mv1.content FROM #{NestedMetadata::MetadatumValue.table_name} AS mv1 WHERE mv1.metadata_key_id = #{id_key.id} AND mv1.entity_mention_id = #{NestedMetadata::EntityMention.table_name}.id) AS word_id, #{NestedMetadata::EntityMention.table_name}.*").all.select{|em| em.word_id =~ / *#{word_id} / || em.word_id =~ / *#{word_id}$/ }.first
  end
  
  def self.blacklab_pids_matching_content(value)
    BlacklabRails::Blacklab.docs({"patt" => '[word=".*'+value.split(" ").join('"][word="')+'.*"]', "number" => self.count})["docs"].map{|doc| doc["docPid"].to_i }
  end
  
  def self.content_contains(values)
    queries = values.map{|value| self.blacklab_pids_matching_content(value) }
    pids = queries.shift
    while queries.count > 0
      pids = pids & queries.shift
    end
    where(:blacklab_pid => pids)
  end
  
  def self.get_user_id(user_id)
    return user_id.split(' ')[1].to_i
  end
  
  def self.locations_in_group(group)
    NestedMetadata::EntityMention.as_locations2(group)
  end
  
  def self.token_count_boundaries
    if Extract.any?
      return self.order(:token_count).limit(1).first.token_count, self.order(token_count: :desc).limit(1).first.token_count
    end
  end
  
  protected
  
  def get_group_entity_count(group, user_id = nil)
    if user_id
      return self.user_locations(group, user_id).count
    else
      return self.locations.has_group_name(group).count
    end
  end
  
end
