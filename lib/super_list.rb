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

    def values
      @values
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

      validates_inclusion_of original_column, { :in => data.values.keys }.merge(options)

      define_method "#{column}" do |*opt|
        opt = opt[0].is_a?(Hash) ? opt[0] : {}
        opt = options.merge(opt)

        key = attributes[column.to_s]
        if opt[:use_i18n]
          I18n.t(key, :scope => opt[:i18n_scope], :default => opt[:i18n_default], :locale => opt[:i18n_locale])
        else
          data.values[key]
        end
      end

      define_method original_column do
        attributes[column.to_s]
      end
    end
  end
end

ActiveRecord::Base.send :include, SuperListActiveRecord
