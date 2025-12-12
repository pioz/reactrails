require "test_helper"

class ReactRendererTest < ActiveSupport::TestCase
  setup do
    Reactrails::ReactRenderer.instance_variable_set(:@context, nil)
  end

  test "combined_source raises if SSR bundle is missing" do
    server_bundle_path = Reactrails::Engine.root.join("app/assets/builds/reactrails.js")
    ssr_bundle_path = Rails.root.join("app/assets/builds/ssr/index.js")
    Reactrails.config.ssr_init_reactrails_bundle_path = ssr_bundle_path
    Reactrails.config.ssr_preload_code = nil

    File.stub(:exist?, ->(path) { path.to_s != server_bundle_path.to_s }) do
      error = assert_raises(RuntimeError) do
        Reactrails::ReactRenderer.send(:combined_source)
      end
      assert_equal "SSR bundle not found: #{server_bundle_path}", error.message
    end
  end

  test "combined_source concatenates preload code, gem bundle and app SSR bundle" do
    server_bundle_path = Reactrails::Engine.root.join("app/assets/builds/reactrails.js")
    ssr_bundle_path = Rails.root.join("app/assets/builds/ssr/index.js")

    Reactrails.config.ssr_init_reactrails_bundle_path = ssr_bundle_path
    Reactrails.config.ssr_preload_code = "// preload"

    File.stub(:exist?, true) do
      File.stub(:read, ->(path) {
        case path.to_s
        when server_bundle_path.to_s then "/* GEM */"
        when ssr_bundle_path.to_s then "/* APP SSR */"
        else raise "unexpected read: #{path}"
        end
      }) do
        combined = Reactrails::ReactRenderer.send(:combined_source)
        assert_equal "// preload\n/* GEM */\n/* APP SSR */", combined
      end
    end
  end

  test "render delegates to NodeRunner with JSON props" do
    runner = Minitest::Mock.new
    runner.expect(:compile, runner, ["/* BUNDLE */"])
    runner.expect(:call, "<div>ok</div>", ["renderComponent", "Hello", "{\"foo\":\"bar\"}"])

    Reactrails::ReactRenderer.stub(:combined_source, "/* BUNDLE */") do
      NodeRunner.stub(:new, ->(*) { runner }) do
        result = Reactrails::ReactRenderer.render("Hello", { foo: "bar" })
        assert_equal "<div>ok</div>", result
      end
    end

    runner.verify
  end

  test "caches NodeRunner context in production" do
    runner = Minitest::Mock.new
    runner.expect(:compile, runner, ["/* BUNDLE */"]) # A mock can be called only 1 time or I get the error "MockExpectationError: No more expects available for :compile:"
    runner.expect(:call, "R1", ["renderComponent", "A", "{}"])
    runner.expect(:call, "R2", ["renderComponent", "B", "{}"])

    env = ActiveSupport::StringInquirer.new("production")

    Reactrails::ReactRenderer.stub(:combined_source, "/* BUNDLE */") do
      Rails.stub(:env, env) do
        NodeRunner.stub(:new, ->(*) { runner }) do
          assert_equal "R1", Reactrails::ReactRenderer.render("A", {})
          assert_equal "R2", Reactrails::ReactRenderer.render("B", {})
        end
      end
    end

    runner.verify
  end
end
