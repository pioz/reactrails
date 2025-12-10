module Reactrails
  class Configuration
    attr_accessor :app_registry_bundle_path

    def initialize
      @app_registry_bundle_path = Rails.root.join("app/assets/builds/ssr/index.js")
    end
  end
end
