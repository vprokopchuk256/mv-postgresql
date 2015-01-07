require 'mv/postgresql/validation/builder/exclusion'
require 'mv/postgresql/validation/builder/trigger/trigger_column'

module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          class Exclusion < Mv::Postgresql::Validation::Builder::Exclusion
            include TriggerColumn
          end
        end
      end
    end
  end
end