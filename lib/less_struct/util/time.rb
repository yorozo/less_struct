# frozen_string_literal: true

require 'time'

# EG: LessStruct::Util::Hash.deep_stringify_keys({a:1})

class LessStruct
  module Util
    module Time
      class << self
        def deep_restore_time_in_hac(hash)
          hash.inject({}) do |result_hash,(k,v)|
            case v
            when ::Hash
              result_hash[k] = deep_restore_time_in_hac(v)
            when Array
              result_hash[k] = v.map {|o| deep_restore_time_in_hac(o) }
            else
              if k.to_s.end_with?("_at") && v.is_a?(::String)
                result_hash[k] = ::Time.parse(v).utc
              else
                result_hash[k] = v
              end
            end
            result_hash
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

LessStruct::Util::Time.deep_restore_time_in_hac(b)
LessStruct::Util::Time.deep_restore_time_in_hac(b)[:a][:a_at].class