require 'mv-core'
require 'mv/postgresql/railtie'

require 'mv/postgresql/constraint/index'

require 'mv/postgresql/validation/exclusion'
require 'mv/postgresql/validation/format'
require 'mv/postgresql/validation/inclusion'
require 'mv/postgresql/validation/length'
require 'mv/postgresql/validation/presence'

ActiveSupport.on_load(:mv_core) do
  #constraints
  Mv::Core::Constraint::Factory.register_constraint(:index, Mv::Postgresql::Constraint::Index)

  #validations
  Mv::Core::Validation::Factory.register_validation(:exclusion, Mv::Postgresql::Validation::Exclusion)
  Mv::Core::Validation::Factory.register_validation(:format, Mv::Postgresql::Validation::Format)
  Mv::Core::Validation::Factory.register_validation(:inclusion, Mv::Postgresql::Validation::Inclusion)
  Mv::Core::Validation::Factory.register_validation(:length, Mv::Postgresql::Validation::Length)
  Mv::Core::Validation::Factory.register_validation(:presence, Mv::Postgresql::Validation::Presence)
end

