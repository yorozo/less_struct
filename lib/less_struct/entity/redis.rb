# frozen_string_literal: true

#
# Subclass this and override methods for your own configuration.
#

require "less_struct/entity/redis_base"

class LessStruct
  module Entity
    class Redis < LessStruct::Entity::RedisBase
      def self.config_entity_kind
        nil
      end

      def self.config_entity_kind_prefix
        nil
      end
      
      def self.config_entity_id_auto_y
        true
      end

      def self.config_redis_duration
        60 * 60 * 1
      end

      def self.config_redis_meta_info_y
        true
      end

      def self.config_redis_format_json_y
        false
      end
    end
  end
end