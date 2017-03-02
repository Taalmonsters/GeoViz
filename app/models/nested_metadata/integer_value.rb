module NestedMetadata
  class IntegerValue < ActiveRecord::Base
    include NestedMetadata::TypedValue
    
    scope :above, -> value { where("content > ?", value.to_i) }
    scope :equal_to, -> value { where("content = ?", value.to_i) }
    scope :below, -> value { where("content < ?", value.to_i) }
    scope :in_range, -> min, max { where("nested_metadata_integer_values.content >= ? AND nested_metadata_integer_values.content <= ?", min.to_i, max.to_i) }
    
    def self.identifier
      "integer"
    end
    
    def self.value_is_valid(value)
      return value.to_s =~ /\A[-+]?[0-9]+\Z/ && value.to_i >= -9223372036854775808 && value.to_i <= +9223372036854775807 ? value.to_i : nil
    end
  end
end
