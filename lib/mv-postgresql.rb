require 'mv-core'
require 'mv/postgresql/validation/base_decorator'
require 'mv/postgresql/railtie'
require 'mv/postgresql/constraint/index'

ActiveSupport.on_load(:mv_core) do
  Mv::Core::Validation::Base.send(:prepend, Mv::Postgresql::Validation::BaseDecorator)
  Mv::Core::Constraint::Factory.register_constraint(:index, Mv::Postgresql::Constraint::Index)
end

