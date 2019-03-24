# frozen_string_literal: true

require "less_struct/entity/redis"

class LessStruct
  module Entity
    module RedisCheck
      class << self
        def call
          results = []

          saved = LessStruct::Entity::Redis.new(id: 100).save
          found = LessStruct::Entity::Redis.find(100)
          results.push saved == found

          LessStruct::Entity::Redis.delete(100)
          results.push LessStruct::Entity::Redis.find(100) == nil

          inner = LessStruct::Entity::Redis.new(a:1)
          saved = LessStruct::Entity::Redis.new(b:2, inner: inner).save
          found = LessStruct::Entity::Redis.find(saved.id)
          results.push saved == found

          # LessStruct::Entity::Redis.clear
          # results.push true

          puts "results #{results}" if LessStruct.use_debug_y
          results.all?
        end
      end
    end
  end
end