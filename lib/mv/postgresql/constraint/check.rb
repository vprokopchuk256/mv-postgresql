module Mv
  module Postgresql
    module Constraint
      class Check < Mv::Core::Constraint::Base
        def initialize description
          super
        end
      end
    end
  end
end