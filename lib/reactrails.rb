require "reactrails/version"
require "reactrails/configuration"
require "reactrails/engine"
require "reactrails/react_renderer"

module Reactrails
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield(config)
    end
  end
end
