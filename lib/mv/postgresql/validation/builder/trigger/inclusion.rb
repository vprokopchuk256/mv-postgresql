require 'mv/postgresql/validation/builder/inclusion'
require 'mv/postgresql/validation/builder/trigger/trigger_column'

module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          class Inclusion < Mv::Postgresql::Validation::Builder::Inclusion
            include TriggerColumn
          end
        end
      end
    end
  end
end