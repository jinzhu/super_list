require 'rubygems'
require 'active_support'

class SuperList
  @@options = { :use_i18n => false}
  @@data = ActiveSupport::OrderedHash.new

  def self.default_option=(options)
    @@options.update(options)
  end

  def initialize(name, values, options={})
    # { :use_i18n => false, :i18n_scope => 'super_list'}
    options = @@options.merge(:i18n_scope => name).merge(options)
    @@data[name] = Data.new(values, options)
  end

  def self.[](name)
    @@data[name]
  end

  class List
    def initialize(data, options)
      @data, @options = data, options
    end

    def to_s(type=:default, options={})
      options = options.merge(@options)
      key = @data[type] || @data[:default]

      return I18n.t(key, :scope => options[:i18n_scope], :default => options[:i18n_default], :locale => options[:locale]) if options[:use_i18n]
      key
    end
  end

  ## Data Store
  class Data
    def initialize(values, options)
      @values, @options = values, options
    end

    def keys
      @values.keys
    end

    def values(type=:default, options={})
      options, type = type, :default if type.is_a?(Hash)
      keys.map {|x| get_value(x, options).to_s(type) }
    end

    def map(type=:default, options={}, &blk)
      keys.zip(values(type,options)).map &blk
    end

    def get_value(key,options={})
      options = @options.merge(options)
      value = @values[key]
      value = value.is_a?(Hash) ? value : {:default => value}
      List.new(value, options)
    end

    def get_key(value,options={})
      keys[values(options).index(value)] rescue nil
    end

    def options
      @options
    end
  end
end


module SuperListActiveRecord
  extend ActiveSupport::Concern

  module ClassMethods
    def super_list(column, data, options={})
      original_column = "original_#{column}".to_sym
      data = SuperList[data]
      options = data.options.merge(options)

      validates_inclusion_of original_column, { :in => data.keys }.merge(options)

      define_method "#{column}" do |*opt|
        opt = opt[0].is_a?(Hash) ? opt[0] : {}
        opt = options.merge(opt)

        data.get_value(attributes[column.to_s], opt)
      end

      define_method original_column do
        attributes[column.to_s]
      end
    end
  end
end

ActiveRecord::Base.send :include, SuperListActiveRecord
