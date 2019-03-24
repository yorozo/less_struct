# frozen_string_literal: true

# LessStruct::Interactor::Simple

class LessStruct
  module Interactor
    module Simple
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def call(*args)
          new(*args).tap(&:call).context
        end
      end

      def initialize(*args)
        @context ||= Context.new(*args)
      end

      def context
        @context
      end

      def call
        raise NotImplementedError, "#{self.class}#call"
      end

      class Context < LessStruct
      end
    end
  end
end