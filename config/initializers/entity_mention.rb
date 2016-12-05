Rails.application.config.to_prepare do
  NestedMetadata::EntityMention.class_eval do
    has_one :latitude, -> { select("#{NestedMetadata::MetadatumValue.table_name}.*").where("#{NestedMetadata::MetadatumValue.table_name}.metadata_key_id IN (#{NestedMetadata::MetadataKey.with_name("latitude").all.map{|key| key.id }.join(",")})") }, class_name: "NestedMetadata::MetadatumValue"
    has_one :longitude, -> { select("#{NestedMetadata::MetadatumValue.table_name}.*").where("#{NestedMetadata::MetadatumValue.table_name}.metadata_key_id IN (#{NestedMetadata::MetadataKey.with_name("longitude").all.map{|key| key.id }.join(",")})") }, class_name: "NestedMetadata::MetadatumValue"
    has_one :name, -> { select("#{NestedMetadata::MetadatumValue.table_name}.*").where("#{NestedMetadata::MetadatumValue.table_name}.metadata_key_id IN (#{NestedMetadata::MetadataKey.with_name("name").all.map{|key| key.id }.join(",")})") }, class_name: "NestedMetadata::MetadatumValue"
    has_one :country, -> { select("#{NestedMetadata::MetadatumValue.table_name}.*").where("#{NestedMetadata::MetadatumValue.table_name}.metadata_key_id IN (#{NestedMetadata::MetadataKey.with_name("country").all.map{|key| key.id }.join(",")})") }, class_name: "NestedMetadata::MetadatumValue"
    
    scope :at_latitude, -> lat { joins(:metadatum_values).merge(NestedMetadata::MetadatumValue.has_key_name("latitude").where(content: lat )) }
    scope :at_longitude, -> lng { joins(:metadatum_values).merge(NestedMetadata::MetadatumValue.has_key_name("longitude").where(content: lng )) }
    
    scope :as_locations, -> { includes(:metadata_group, :latitude, :longitude, :name, :country) }
    
    def siblings
      source_document.entity_mentions.as_locations.where.not(id: self.id)
    end
  end
end