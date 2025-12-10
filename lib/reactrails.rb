require "reactrails/configuration"
require "reactrails/engine"
require "reactrails/react_renderer"
require "reactrails/version"

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
