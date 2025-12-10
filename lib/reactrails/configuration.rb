class Reactrails::Configuration
  attr_accessor :app_registry_bundle_path, :ssr_preload_code

  def initialize
    @app_registry_bundle_path = Rails.root.join("app/assets/builds/ssr/index.js")
    @ssr_preload_code = nil
  end
end
