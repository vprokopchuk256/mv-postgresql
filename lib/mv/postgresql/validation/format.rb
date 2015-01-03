module Mv
  module Postgresql
    module Validation
      class Format < Mv::Core::Validation::Base
        attr_reader :with, :check_name

        validates :with, presence: true
        validates :check_name, absence: { message: 'allowed when :as == :trigger' }, unless: :check?

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts)

          @with = opts.with_indifferent_access[:with]
          @check_name = opts.with_indifferent_access[:check_name] || default_check_name
        end

        def to_a
          super + [with.to_s, check_name.to_s]
        end

        protected 

        def available_as
          [:trigger, :check]
        end
        
        def default_as
          :check 
        end

        def default_check_name
          "chk_mv_#{table_name}_#{column_name}"  if check?
        end

        private 

        def check?
          as.try(:to_sym) == :check
        end       
      end
    end
  end
end