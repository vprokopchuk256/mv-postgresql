require 'mv/postgresql/route/check'

require 'mv/postgresql/constraint/check'

require 'mv/postgresql/constraint/builder/trigger'
require 'mv/postgresql/constraint/builder/check'

require 'mv/postgresql/validation/exclusion'
require 'mv/postgresql/validation/format'
require 'mv/postgresql/validation/inclusion'
require 'mv/postgresql/validation/length'
require 'mv/postgresql/validation/presence'
require 'mv/postgresql/validation/absence'
require 'mv/postgresql/validation/custom'

require 'mv/postgresql/validation/builder/trigger/exclusion'
require 'mv/postgresql/validation/builder/trigger/inclusion'
require 'mv/postgresql/validation/builder/trigger/length'
require 'mv/postgresql/validation/builder/trigger/format'
require 'mv/postgresql/validation/builder/trigger/presence'
require 'mv/postgresql/validation/builder/trigger/absence'
require 'mv/postgresql/validation/builder/trigger/uniqueness'
require 'mv/postgresql/validation/builder/trigger/custom'

require 'mv/postgresql/validation/active_model_presenter/format'

require 'mv/postgresql/active_record/connection_adapters/postgresql_adapter_decorator'

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
  :presence  => Mv::Postgresql::Validation::Presence,
  :absence   => Mv::Postgresql::Validation::Absence,
  :custom   => Mv::Postgresql::Validation::Custom
)

#validation builders in trigger
Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builders(
  Mv::Postgresql::Validation::Exclusion => Mv::Postgresql::Validation::Builder::Trigger::Exclusion,
  Mv::Postgresql::Validation::Inclusion => Mv::Postgresql::Validation::Builder::Trigger::Inclusion,
  Mv::Postgresql::Validation::Length    => Mv::Postgresql::Validation::Builder::Trigger::Length,
  Mv::Postgresql::Validation::Format    => Mv::Postgresql::Validation::Builder::Trigger::Format,
  Mv::Postgresql::Validation::Presence  => Mv::Postgresql::Validation::Builder::Trigger::Presence,
  Mv::Postgresql::Validation::Absence   => Mv::Postgresql::Validation::Builder::Trigger::Absence,
  Mv::Core::Validation::Uniqueness      => Mv::Postgresql::Validation::Builder::Trigger::Uniqueness,
  Mv::Postgresql::Validation::Custom    => Mv::Postgresql::Validation::Builder::Trigger::Custom,
)

#validation builders in check
Mv::Postgresql::Constraint::Builder::Check.validation_builders_factory.register_builders(
  Mv::Postgresql::Validation::Exclusion => Mv::Postgresql::Validation::Builder::Exclusion,
  Mv::Postgresql::Validation::Inclusion => Mv::Postgresql::Validation::Builder::Inclusion,
  Mv::Postgresql::Validation::Length    => Mv::Core::Validation::Builder::Length,
  Mv::Postgresql::Validation::Format    => Mv::Postgresql::Validation::Builder::Format,
  Mv::Postgresql::Validation::Presence  => Mv::Core::Validation::Builder::Presence,
  Mv::Postgresql::Validation::Absence   => Mv::Core::Validation::Builder::Absence,
  Mv::Postgresql::Validation::Custom   => Mv::Core::Validation::Builder::Custom
)

#validation active model presenters
Mv::Core::Validation::ActiveModelPresenter::Factory.register_presenters(
  Mv::Postgresql::Validation::Exclusion   => Mv::Core::Validation::ActiveModelPresenter::Exclusion,
  Mv::Postgresql::Validation::Inclusion   => Mv::Core::Validation::ActiveModelPresenter::Inclusion,
  Mv::Postgresql::Validation::Length      => Mv::Core::Validation::ActiveModelPresenter::Length,
  Mv::Postgresql::Validation::Presence    => Mv::Core::Validation::ActiveModelPresenter::Presence,
  Mv::Postgresql::Validation::Absence     => Mv::Core::Validation::ActiveModelPresenter::Absence,
  Mv::Postgresql::Validation::Format      => Mv::Postgresql::Validation::ActiveModelPresenter::Format
)

::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(
  :prepend,
  Mv::Postgresql::ActiveRecord::ConnectionAdapters::PostgresqlAdapterDecorator
)
