module Mv
  module Postgresql
    module Validation
      class Format < Mv::Core::Validation::Base
        attr_reader :with

        validates :with, presence: true

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts)

          @with = opts.with_indifferent_access[:with]
        end

        def to_a
          super + [with.to_s]
        end

        protected 
        
        def default_as
          :check 
        end
      end
    end
  end
end