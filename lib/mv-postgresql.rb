require 'mv-core'
require 'mv/postgresql/railtie'

require 'mv/postgresql/route/check'

require 'mv/postgresql/constraint/check'

require 'mv/postgresql/constraint/builder/trigger'

require 'mv/postgresql/validation/exclusion'
require 'mv/postgresql/validation/format'
require 'mv/postgresql/validation/inclusion'
require 'mv/postgresql/validation/length'
require 'mv/postgresql/validation/presence'

require 'mv/postgresql/validation/builder/trigger/exclusion'
require 'mv/postgresql/validation/builder/trigger/inclusion'
require 'mv/postgresql/validation/builder/trigger/length'
require 'mv/postgresql/validation/builder/trigger/format'
require 'mv/postgresql/validation/builder/trigger/presence'
require 'mv/postgresql/validation/builder/trigger/uniqueness'

ActiveSupport.on_load(:mv_core) do
  #router
  Mv::Core::Router.define_route(:check, Mv::Postgresql::Route::Check)

  #constraints
  Mv::Core::Constraint::Factory.register_constraint(:check, Mv::Postgresql::Constraint::Check)

  #constraint builders
  Mv::Core::Constraint::Builder::Factory.register_builder(Mv::Core::Constraint::Trigger, 
                                                          Mv::Postgresql::Constraint::Builder::Trigger)

  #validations
  Mv::Core::Validation::Factory.register_validation(:exclusion, Mv::Postgresql::Validation::Exclusion)
  Mv::Core::Validation::Factory.register_validation(:format, Mv::Postgresql::Validation::Format)
  Mv::Core::Validation::Factory.register_validation(:inclusion, Mv::Postgresql::Validation::Inclusion)
  Mv::Core::Validation::Factory.register_validation(:length, Mv::Postgresql::Validation::Length)
  Mv::Core::Validation::Factory.register_validation(:presence, Mv::Postgresql::Validation::Presence)

  #validation builders in trigger
  Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builder(
    Mv::Postgresql::Validation::Exclusion, 
    Mv::Postgresql::Validation::Builder::Trigger::Exclusion
  )
  Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builder(
    Mv::Postgresql::Validation::Inclusion, 
    Mv::Postgresql::Validation::Builder::Trigger::Inclusion
  )
  Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builder(
    Mv::Postgresql::Validation::Length, 
    Mv::Postgresql::Validation::Builder::Trigger::Length
  )
  Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builder(
    Mv::Postgresql::Validation::Format, 
    Mv::Postgresql::Validation::Builder::Trigger::Format
  )
  Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builder(
    Mv::Postgresql::Validation::Presence, 
    Mv::Postgresql::Validation::Builder::Trigger::Presence
  )
  Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builder(
    Mv::Core::Validation::Uniqueness, 
    Mv::Postgresql::Validation::Builder::Trigger::Uniqueness
  )


end

