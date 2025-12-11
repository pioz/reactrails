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
      ssr_preload_code = Reactrails.config.ssr_preload_code
      server_bundle_path = Reactrails::Engine.root.join("app/assets/builds/reactrails.js")
      ssr_init_reactrails_bundle_path = Reactrails.config.ssr_init_reactrails_bundle_path
      [ssr_preload_code, File.read(server_bundle_path), File.read(ssr_init_reactrails_bundle_path)].compact.join("\n")
    end
  end
end
