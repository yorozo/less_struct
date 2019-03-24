# frozen_string_literal: true

# require 'hash_dot' # TODO:

require "ostruct"
require "less_struct/util/hash"
require "less_struct/check"

require "less_struct/package"

class LessStruct
  class << self
    def check
      LessStruct::Check.call
    end

    def use_debug_y
      @@use_debug_y ||= false
    end

    def use_debug_y=(val)
      @@use_debug_y = val
    end

    def use_to_h_with_symbol_key_y
      @@use_to_h_with_symbol_key_y ||= false
    end

    def use_to_h_with_symbol_key_y=(val)
      @@use_to_h_with_symbol_key_y = val
    end

    private

    def instance
      @instance ||= new
    end
  end

  def initialize(*args)
    @base = ::OpenStruct.new(args_array_to_hash(*args))
  end

  def base
    @base
  end

  def to_h
    unless klass.use_to_h_with_symbol_key_y
      LessStruct::Util::Hash.deep_stringify_keys(base.to_h)
    else
      base.to_h
    end
  end

  def to_json(*args)
    to_h.to_json
  end

  def to_s
    inspect
  end

  def inspect
    content = "#{klass} #{base.to_h.map{|k, v| "#{k}=#{v.inspect}"}.join(', ')}".strip
    "#<#{content}>"
  end

  def ==(other)
    base == other.base
  end

  def add(*args)
    args_array_to_hash(*args).each do |k, v|
      base[k] = v
    end
    self
  end

  def del(*args)
    args.each do |name|
      base.delete_field(name)
    end
    self
  end

  def slice(*args)
    # klass.new(base.to_h.slice(*args))
    args = args.map(&:to_s)
    klass.new(base.to_h.to_a.select{ |o| args.include?(o[0].to_s) }.to_h)
  end

  def except(*args)
    args = args.map(&:to_s)
    klass.new(base.to_h.to_a.reject{ |o| args.include?(o[0].to_s) }.to_h)
  end

  def optional
    base
  end

  def freeze
    base.freeze
    self
  end

  def hash
    klass.hash ^ base.hash
  end

  def marshal_dump
    @base
  end

  def marshal_load(base)
    @base = base
  end

  private

  def klass
    self.class
  end

  def method_missing(method_name, *args, &block)
    if respond_to_missing?(method_name)
      base.send(method_name, *args, &block)
    else
      raise_no_method_error(method_name)
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    super || base.respond_to?(method_name) || writer_method?(method_name)
  end

  def writer_method?(method_name)
    method_name.to_s.match?(/\A[^=]+=\z/)
  end

  def raise_no_method_error(method_name)
    raise NoMethodError, "undefined method `#{method_name}' for #{self.inspect}"
  end

  def args_array_to_hash(*args)
    args.first.respond_to?(:to_h) ? args.first.to_h : {}
  end
end

