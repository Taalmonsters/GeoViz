module NestedMetadata
  class FloatValue < ActiveRecord::Base
    include NestedMetadata::TypedValue
    
    scope :above, -> value { where("content > ?", value.to_f) }
    scope :equal_to, -> value { where("content = ?", value.to_f) }
    scope :below, -> value { where("content < ?", value.to_f) }
    scope :in_range, -> min, max { where("nested_metadata_float_values.content >= ? AND nested_metadata_float_values.content <= ?", min.to_f, max.to_f) }
    
    def self.identifier
      "float"
    end
    
    def self.value_is_valid(value)
      value = value.to_s
      return value =~ /\A[-+]?[0-9]*[\.\,][0-9]+\Z/ && value.gsub(',','.').to_f >= -999999999.999999 && value.gsub(',','.').to_f <= 999999999.999999 ? value.gsub(',','.').to_f : nil
    end
  end
end
