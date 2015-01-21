require 'mv/postgresql/validation/check_support'

module Mv
  module Postgresql
    module Validation
      class Format < Mv::Core::Validation::Base
        include CheckSupport

        attr_reader :with

        validates :with, presence: true

        def initialize(table_name, column_name, opts)
          opts = { with: opts } unless opts.is_a?(Hash)
          
          super(table_name, column_name, opts)

          @with = opts.with_indifferent_access[:with]
        end

        def to_a
          super + [with.to_s]
        end
      end
    end
  end
end