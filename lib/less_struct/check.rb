# frozen_string_literal: true

require "less_struct"

module LessStruct::Check
  class << self
    def call
      results = []

      o = LessStruct.new(a:1, b:2)
      results.push o.to_h.keys == ["a", "b"]
      results.push o.a == 1
      results.push o[:a] == 1
      results.push o["a"] == 1

      o.add(c: 1, d:2)
      results.push o.to_h.keys == ["a", "b", "c", "d"]

      o.del(:a, :d)
      results.push o.to_h.keys == ["b", "c"]

      begin
        o.x
      rescue => e
      ensure
        results.push e.is_a?(NoMethodError)
      end

      puts "results #{results}" if LessStruct.use_debug_y
      results.all?
    end
  end
end
