# frozen_string_literal: true

require "less_struct/entity/base"
require "less_struct/entity/redis_check"
require "redis"
require "json"
require "less_struct/util/time"

# CHECK: LessStruct::Entity::Redis.check

class LessStruct
  module Entity
    class RedisBase < LessStruct::Entity::Base
      class << self
        def check
          LessStruct::Entity::RedisCheck.call
        end

        def redis
          @redis ||= if ENV["LESS_STRUCT_REDIS_URL"]
            ::Redis.new(url: ENV["LESS_STRUCT_REDIS_URL"])
          elsif ::Redis.current
            ::Redis.current
          else
            ::Redis.new
          end
        end

        private

        def find_impl(id)
          return unless _store_format = redis.get(key(kind, id))
          _from_store_format(_store_format)
        end

        def delete_impl(id)
          redis.del(key(kind, id))
        end

        def clear_impl
          redis.scan_each(match: "#{kind}:*") do |key|
            puts "clear key #{key}" if use_debug_y
            redis.del(key)
          end
        end

        def all
          redis.scan_each(match: "#{kind}:*").to_a
        end

        def _from_store_format(_store_format)
          unless config_redis_format_json_y
            Marshal.load(_store_format)
          else
            hash = JSON.parse(_store_format)
            # hash = LessStruct::Util::Time.deep_restore_time_in_hac(hash)
            new(hash)
          end
        end
      end

      private

      def save_impl
        _add_info
        _save_as_redis_entity
        self
      end

      def _to_store_format
        unless klass.config_redis_format_json_y
          Marshal.dump(self)
        else
          self.to_json
        end
      end

      def _add_info
        return unless klass.config_redis_meta_info_y

        self.redis_duration = klass.config_redis_duration
        self.redis_set_at = Time.at(now.to_i).utc
        self.redis_end_at = redis_duration > 0 ? Time.at(now.to_i + redis_duration).utc : nil
      end

      def _save_as_redis_entity
        if klass.config_redis_duration > 0
          klass.redis.setex key, klass.config_redis_duration, _to_store_format
        else
          klass.redis.set key, _to_store_format
        end
      end
    end
  end
end

__END__

it "warming‐up tests" do
  t1 = Time.at(0.100000000)
  t2 = Time.at(0.1).utc
  expect( t1 ).to eq( t2 )

  now = Time.now
  r1 = now.to_r
  r2 = r1.to_s.to_r
  expect( now ).to eq( Time.at(r1) )
  expect( now ).to eq( Time.at(r2) )
  expect( now ).to_not eq( Time.at(now.to_f) )

  expect( t1.utc.iso8601(0).to_json ).to eq( "\"1970-01-01T00:00:00Z\"" )
  expect( LessStruct::JsonIo::TimeWithObjectFormat.at(0.1).to_json ).to eq( "{\"__object_time__\":{\"iso8601\":\"1970-01-01T00:00:00Z\",\"rounded_timestamp\":0.1,\"rational\":\"3602879701896397/36028797018963968\"}}" )
end