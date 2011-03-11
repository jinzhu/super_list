require 'rubygems'
require 'active_support'

class SuperList
  @@options = { :use_i18n => false, :format => :default}
  @@data = ActiveSupport::OrderedHash.new

  def self.options=(options)
    @@options.update(options)
  end

  def self.options
    @@options
  end

  def initialize(name, values, options={})
    options = { :i18n_scope => name}.merge(options)
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

    def values(format=nil, opts={})
      opts, format = format, nil if format.is_a?(Hash)
      keys.map {|key| get_value(key, format, opts) }
    end

    def get_value(key, format=nil, opts={})
      opts = options.merge(opts)

      value = @values[key]
      format = format || opts[:format]
      result = value.is_a?(Hash) ? value[format] : value

      return I18n.t(result, :scope => opts[:i18n_scope], :default => opts[:i18n_default], :locale => opts[:locale]) if opts[:use_i18n]
      result
    end

    def get_key(value, opts={})
      keys[values(opts).index(value)] rescue nil
    end

    def map(format=nil, opts={}, &blk)
      keys.zip(values(format, opts)).map &blk
    end

    def select_options(format=nil, opts={}, &blk)
      values(format, opts).zip(keys).map &blk
    end

    def options
      SuperList.options.merge(@options)
    end
  end
end


module SuperListActiveRecord
  extend ActiveSupport::Concern

  module ClassMethods
    def super_list(column, data, options={})
      data = SuperList[data]
      options = data.options.merge(options)

      before_validation do
        value = attributes[column.to_s]
        keys  = data.keys

        if !keys.include?(value)
          index = data.values.find_index(value)

          if index
            self.send("#{column}=", keys[index])
          elsif !options[:no_validation]
            self.errors.add(column, I18n.t('errors.messages.inclusion'))
            return false
          end
        end
      end

      define_method "#{column}" do |*opts|
        key = attributes[column.to_s]
        if opts.blank?
          key
        else
          format = opts[0].is_a?(Symbol) ? opts[0] : nil
          opts   = opts[1].is_a?(Hash) ? opts[1] : (opts[0].is_a?(Hash) ? opts[0] : {})
          data.get_value(key, format, options.merge(opts))
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, SuperListActiveRecord
