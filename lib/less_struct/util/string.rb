# frozen_string_literal: true

# EG: LessStruct::Util::String.to_snake("Test::TestOne") => "test/test_one"
# EG: LessStruct::Util::String.to_camel("test/test_one") => "Test::TestOne"

class LessStruct
  module Util
    module String
      class << self
        def to_class_code(klass)
          to_snake(klass.to_s).tr('/','.')
        end
  
        def from_class_code(code)
          to_camel(code.tr('.','/'))
        end

        def to_snake(string)
          string
          .gsub('::', '/')
          .gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
          .gsub(/([a-z\d])([A-Z])/,'\1_\2')
          .downcase
        end

        def to_camel(string)
          string
          .split("/")
          .map(&:capitalize)
          .map{ |segment| segment.split("_").map(&:capitalize).join }
          .join("/")
          .gsub("/", "::")
        end
      end
    end
  end
end