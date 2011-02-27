require 'rubygems'
require 'active_support'

class SuperList
  @@options = { :use_i18n => true, :namespace => 'super_list' }
  @@data = ActiveSupport::OrderedHash.new

  # I18n
  # SuperList.new("Gender", {"M" => "Man", "F" => "Female"}, :allow_blank => true)
  # super_list :gender, 'Gender'
  #
  # self.available_gender = ["M", "F"]
  # self.gender => 'Man'
  def self.default_option
    @@options
  end

  def self.default_option=(options)
    @@options.update(options)
  end

  def initialize(name, values, options={})
    @options = self.class.default_option.merge(options)
    @@data[name] = Data.new(values, @options)
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
      data = SuperList[data]
      validates_inclusion_of column, { :in => data.values.keys }.merge(data.options.merge(options))
    end
  end
end

ActiveRecord::Base.send :include, SuperListActiveRecord
