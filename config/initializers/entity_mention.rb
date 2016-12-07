Rails.application.config.to_prepare do
  NestedMetadata::EntityMention.class_eval do
    has_one :latitude, -> { select("#{NestedMetadata::MetadatumValue.table_name}.*").where("#{NestedMetadata::MetadatumValue.table_name}.metadata_key_id IN (#{NestedMetadata::MetadataKey.with_name("latitude").all.map{|key| key.id }.join(",")})") }, class_name: "NestedMetadata::MetadatumValue"
    has_one :longitude, -> { select("#{NestedMetadata::MetadatumValue.table_name}.*").where("#{NestedMetadata::MetadatumValue.table_name}.metadata_key_id IN (#{NestedMetadata::MetadataKey.with_name("longitude").all.map{|key| key.id }.join(",")})") }, class_name: "NestedMetadata::MetadatumValue"
    has_one :name, -> { select("#{NestedMetadata::MetadatumValue.table_name}.*").where("#{NestedMetadata::MetadatumValue.table_name}.metadata_key_id IN (#{NestedMetadata::MetadataKey.with_name("name").all.map{|key| key.id }.join(",")})") }, class_name: "NestedMetadata::MetadatumValue"
    has_one :country, -> { select("#{NestedMetadata::MetadatumValue.table_name}.*").where("#{NestedMetadata::MetadatumValue.table_name}.metadata_key_id IN (#{NestedMetadata::MetadataKey.with_name("country").all.map{|key| key.id }.join(",")})") }, class_name: "NestedMetadata::MetadatumValue"
    
    scope :annotated_by, -> { select("#{NestedMetadata::EntityMention.table_name}.*, (SELECT a.user_id FROM #{Audited::Audit.table_name} AS a WHERE a.auditable_type = 'NestedMetadata::EntityMention' AND a.auditable_id = #{NestedMetadata::EntityMention.table_name}.id LIMIT 1) AS annotated_by") }
    
    scope :at_latitude, -> lat { joins(:metadatum_values).merge(NestedMetadata::MetadatumValue.has_key_name("latitude").where(content: lat )) }
    scope :at_longitude, -> lng { joins(:metadatum_values).merge(NestedMetadata::MetadatumValue.has_key_name("longitude").where(content: lng )) }
    
    scope :as_locations, -> { includes(:metadata_group, :latitude, :longitude, :name, :country, :audits) }
    
    def siblings
      source_document.entity_mentions.as_locations.where.not(id: self.id)
    end
    
    def self.as_locations2(group)
      select("#{NestedMetadata::EntityMention.table_name}.*, #{self.with_all_values(group).join(", ")}").where("#{NestedMetadata::EntityMention.table_name}.metadata_group_id = ?", group.id)
    end
    
    def self.with_all_values(group)
      arr = [ "(SELECT em_group.name FROM #{NestedMetadata::MetadataGroup.table_name} AS em_group WHERE em_group.id = #{group.id}) AS group_name" ]
      arr << "(SELECT a.user_id FROM #{Audited::Audit.table_name} AS a WHERE a.auditable_type = 'NestedMetadata::EntityMention' AND a.auditable_id = #{NestedMetadata::EntityMention.table_name}.id LIMIT 1) AS annotated_by_id" if group.name.eql?("Annotations")
      group.metadata_keys.each do |key|
        kkey = key.name.gsub(/ /,'_')
        arr << "(SELECT mv_#{kkey}.content FROM #{NestedMetadata::MetadatumValue.table_name} AS mv_#{kkey} WHERE mv_#{kkey}.entity_mention_id = #{NestedMetadata::EntityMention.table_name}.id AND mv_#{kkey}.metadata_key_id = #{key.id} LIMIT 1) AS #{key.name}_str"
      end
      arr
    end
  end
end