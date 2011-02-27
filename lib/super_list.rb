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

  ## Data Store
  class Data
    def initialize(values, options)
      @values, @options = values, options
    end

    def keys
      @values.keys
    end

    def values(options={})
      keys.map {|x| get_value(x, options) }
    end

    def get_value(key,options={})
      options = @options.merge(options)
      if options[:use_i18n]
        I18n.t(key, :scope => options[:i18n_scope], :default => options[:i18n_default], :locale => options[:locale])
      else
        @values[key]
      end
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
