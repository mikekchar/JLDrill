require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'

  add_group 'Context', 'lib/Context'
  add_group 'Models', 'lib/jldrill/model'
  add_group 'Contexts', 'lib/jldrill/contexts'
  add_group 'Old UI', 'lib/jldrill/oldUI'
  add_group 'Views', 'lib/jldrill/views'
end if ENV['COVERAGE']
