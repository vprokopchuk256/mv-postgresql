module Mv
  module Postgresql
    module Validation
      class Length < Mv::Core::Validation::Length
        attr_reader :check_name

        validates :check_name, absence: { message: 'allowed when :as == :trigger' }, unless: :check?

        def initialize(table_name, column_name, opts)
          super

          @check_name = opts.with_indifferent_access[:check_name] || default_check_name
        end

        def to_a
          super + [check_name.to_s]
        end

        protected 

        def available_as
          [:trigger, :check]
        end
        
        def default_as
          :check 
        end

        protected
        
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