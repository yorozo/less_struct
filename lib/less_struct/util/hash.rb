# frozen_string_literal: true

require 'time'

# EG: LessStruct::Util::Hash.deep_stringify_keys({a:1})

class LessStruct
  module Util
    module Hash
      class << self
        def deep_stringify_keys(hash)
          deep_transform_keys_in_hac(hash, &:to_s)
        end

        def deep_symbolize_keys(hash)
          deep_transform_keys_in_hac(hash, &:to_sym)
        end

        def deep_transform_keys(hash, &block)
          deep_transform_keys_in_hac(hash, &block)
        end

        def deep_transform_values(hash, &block)
          deep_transform_values_in_hac(hash, &block)
        end

        # def deep_restore_time_in_hac(hash)
        #   hash.inject({}) do |result_hash,(k,v)|
        #     case v
        #     when ::Hash
        #       result_hash[k] = deep_restore_time_in_hac(v)
        #     when Array
        #       result_hash[k] = v.map {|o| deep_restore_time_in_hac(o) }
        #     else
        #       if k.to_s.end_with?("_at") && v.is_a?(::String)
        #         result_hash[k] = Time.parse(v).utc
        #       else
        #         result_hash[k] = v
        #       end
        #     end
        #     result_hash
        #   end
        # end

        private
  
        def deep_transform_keys_in_hac(object, &block)
          case object
          when ::Hash
            object.keys.each do |key|
              value = object.delete(key)
              object[yield(key)] = deep_transform_keys_in_hac(value, &block)
            end
            object
          when Array
            object.map! { |element| deep_transform_keys_in_hac(element, &block) }
          else
            object
          end
        end

        def deep_transform_values_in_hac(object, &block)
          case object
          when ::Hash
            object.each_with_object({}) do |(key, value), result|
              result[key] = deep_transform_values_in_hac(value, &block)
            end
          when Array
            object.map {|element| deep_transform_values_in_hac(element, &block) }
          else
            yield(object)
          end
        end
      end
    end
  end
end

__END__

a = {
	a:1,
	a_at: Time.now.utc.to_s,
}

b = {
  b:2,
  b_at: Time.now.utc.to_s,
  a: a,
}

LessStruct::Util::Hash.deep_restore_time_in_hac(b)
LessStruct::Util::Hash.deep_restore_time_in_hac(b)[:a][:a_at]