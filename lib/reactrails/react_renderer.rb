require "execjs"

module Reactrails
  class ReactRenderer
    class << self
      def render(componentName, props = {})
        js_props = props.to_json
        context.call("renderComponent", componentName, js_props)
      end

      private

      def context
        # Cache in production
        if Rails.env.production?
          @context ||= ExecJS.compile(combined_source)
        else
          ExecJS.compile(combined_source)
        end
      end

      def combined_source
        app_registry_bundle_path = Rails.root.join("app/assets/builds/ssr/index.js")
        server_bundle_path = Reactrails::Engine.root.join("vendor/react_server_rendering.js")
        File.read(app_registry_bundle_path) + "\n" + File.read(server_bundle_path)
      end
    end
  end
end
