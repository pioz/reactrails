require "execjs"

class Reactrails::ReactRenderer
  @context_mutex = Mutex.new

  class << self
    def render(component_name, props = {})
      js_props = props.to_json
      context.call("renderComponent", component_name, js_props)
    end

    private

    def context
      # Cache in production
      if Rails.env.production?
        @context_mutex.synchronize do
          @context ||= ExecJS.compile(combined_source)
        end
      else
        ExecJS.compile(combined_source)
      end
    end

    def combined_source
      app_registry_bundle_path = Reactrails.config.app_registry_bundle_path
      server_bundle_path = Reactrails::Engine.root.join("vendor/react_server_rendering.js")
      "#{File.read(app_registry_bundle_path)}\n#{File.read(server_bundle_path)}"
    end
  end
end
