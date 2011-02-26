module ActiveSupport
  module SuperList
    module Model
      extend ActiveSupport::Concern

      module ClassMethods
        def super_list(column, data, options={})
          validates_inclusion_of column, :in => data.values.keys, data.options.merge(options)
        end
      end
    end
  end
end
