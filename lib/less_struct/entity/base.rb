# frozen_string_literal: true

require "less_struct"
require "less_struct/util/key"
require "less_struct/util/string"

class LessStruct
  module Entity
    class Base < LessStruct
      include LessStruct::Util::Key

      class << self
        def find(id)
          find_impl(id)
        end

        def save(*args)
          new(*args).save
        end

        def delete(id)
          delete_impl(id)
        end

        def clear
          clear_impl
        end

        private

        def kind_impl
          kind_body = config_entity_kind || LessStruct::Util::String.to_class_code(self)
          [config_entity_kind_prefix,kind_body].compact.join(".") 
        end
      end

      def save
        save_impl
      end

      def delete
        klass.delete(id)
      end
    end
  end
end