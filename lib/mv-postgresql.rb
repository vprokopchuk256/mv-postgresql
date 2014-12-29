require 'mv-core'
require 'mv/postgresql/validation/base_decorator'
require 'mv/postgresql/railtie'

ActiveSupport.on_load(:mv_core) do
  Mv::Core::Validation::Base.send(:prepend, Mv::Postgresql::Validation::BaseDecorator)
end

