require 'active_support'

require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash'

require 'forwardable'
require 'singleton'

Dir['./lib/arsenal/**/*.rb'].each do |f| require f end
