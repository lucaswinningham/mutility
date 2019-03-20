require_relative 'boot'

require 'active_record/railtie'

Bundler.require(*Rails.groups)
require 'mutility'

module Dummy
  class Application < Rails::Application
    config.load_defaults 5.1
    config.api_only = true
  end
end

