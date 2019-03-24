# frozen_string_literal: true

require 'securerandom'

class LessStruct
  module Util
    module Key
      def self.included(klass)
        klass.extend(ClassMethods)
      end
  
      module ClassMethods
        def kind
          kind_impl
        end

        def key(kind, id)
          [kind, id].join(":")
        end
      end

      def kind
        self[:kind] = klass.kind
      end

      def kind=(kind)
        raise "use class method for custom kind name"
      end

      def id
        if klass.config_entity_id_auto_y
          self[:id] ||= auto_id
        else
          raise "set 'id' before save" unless self[:id]
        end
      end

      def auto_id
        rand_sep = "_"
        "#{(now.to_f*1000).to_i}#{rand_sep}#{SecureRandom.hex(4)}"
      end

      def key
        klass.key(kind, id)
      end

      def now
        @now ||= ::Time.now.utc
      end
    end
  end
end