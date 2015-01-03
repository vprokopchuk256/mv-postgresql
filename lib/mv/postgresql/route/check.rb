module Mv
  module Postgresql
    module Route
      class Check
        attr_reader :validation

        def initialize(validation)
          @validation = validation
        end

        def route
          [Mv::Core::Constraint::Description.new(validation.check_name, :check)]
        end
      end
    end
  end
end