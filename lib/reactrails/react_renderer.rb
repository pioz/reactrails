require_relative "node_runner"

class Reactrails::ReactRenderer
  @context_mutex = Mutex.new

  class << self
    def render(component_name, props = {})
      context.call("renderComponent", component_name, props.to_json)
    end

    private

    def context
      # Cache in production
      if Rails.env.production?
        @context_mutex.synchronize do
          @context ||= NodeRunner.new.compile(combined_source)
        end
      else
        NodeRunner.new.compile(combined_source)
      end
    end

    def combined_source
      ssr_preload_code = Reactrails.config.ssr_preload_code
      server_bundle_path = Reactrails::Engine.root.join("app/assets/builds/reactrails.js")
      ssr_init_reactrails_bundle_path = Reactrails.config.ssr_init_reactrails_bundle_path
      [server_bundle_path, ssr_init_reactrails_bundle_path].each do |path|
        raise "SSR bundle not found: #{path}" unless File.exist?(path)
      end

      [ssr_preload_code, File.read(server_bundle_path), File.read(ssr_init_reactrails_bundle_path)].compact.join("\n")
    end
  end
end
