require 'mv-core'
require 'mv/postgresql/railtie'

require 'mv/postgresql/route/check'

require 'mv/postgresql/constraint/check'

require 'mv/postgresql/constraint/builder/trigger'
require 'mv/postgresql/constraint/builder/check'

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
  Mv::Core::Constraint::Builder::Factory.register_builders(
    Mv::Core::Constraint::Trigger => Mv::Postgresql::Constraint::Builder::Trigger,
    Mv::Postgresql::Constraint::Check => Mv::Postgresql::Constraint::Builder::Check
  )

  #validations
  Mv::Core::Validation::Factory.register_validations(
    :exclusion => Mv::Postgresql::Validation::Exclusion,
    :format    => Mv::Postgresql::Validation::Format,
    :inclusion => Mv::Postgresql::Validation::Inclusion,
    :length    => Mv::Postgresql::Validation::Length,
    :presence  => Mv::Postgresql::Validation::Presence
  )

  #validation builders in trigger
  Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builders(
    Mv::Postgresql::Validation::Exclusion => Mv::Postgresql::Validation::Builder::Trigger::Exclusion,
    Mv::Postgresql::Validation::Inclusion => Mv::Postgresql::Validation::Builder::Trigger::Inclusion,
    Mv::Postgresql::Validation::Length    => Mv::Postgresql::Validation::Builder::Trigger::Length,
    Mv::Postgresql::Validation::Format    => Mv::Postgresql::Validation::Builder::Trigger::Format,
    Mv::Postgresql::Validation::Presence  => Mv::Postgresql::Validation::Builder::Trigger::Presence,
    Mv::Core::Validation::Uniqueness      => Mv::Postgresql::Validation::Builder::Trigger::Uniqueness
  )

  #validation builders in check
  Mv::Postgresql::Constraint::Builder::Check.validation_builders_factory.register_builders(
    Mv::Postgresql::Validation::Exclusion => Mv::Postgresql::Validation::Builder::Exclusion,
    Mv::Postgresql::Validation::Inclusion => Mv::Postgresql::Validation::Builder::Inclusion,
    Mv::Postgresql::Validation::Length    => Mv::Core::Validation::Builder::Length,
    Mv::Postgresql::Validation::Format    => Mv::Postgresql::Validation::Builder::Format,
    Mv::Postgresql::Validation::Presence  => Mv::Core::Validation::Builder::Presence
  )

end

