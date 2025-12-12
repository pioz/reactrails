require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include Reactrails::ApplicationHelper

  test "render_component" do
    html = render_component("Hello", { name: "Foo" })

    assert_equal "<div data-react-component=\"Hello\" data-react-props=\"{&quot;name&quot;:&quot;Foo&quot;}\"></div>", html
  end

  test "render_component with span div" do
    html = render_component("Hello", {}, tag: :span)

    assert_equal "<span data-react-component=\"Hello\" data-react-props=\"{}\"></span>", html
  end

  test "render_component with html options" do
    html = render_component("Hello", {}, html_options: { class: "text-primary" })

    assert_equal "<div class=\"text-primary\" data-react-component=\"Hello\" data-react-props=\"{}\"></div>", html
  end

  test "render_component with prerender" do
    Reactrails::ReactRenderer.stub(:render, "<p>SSR</p>") do
      html = render_component("Hello", {}, prerender: true)

      assert_equal "<div data-react-component=\"Hello\" data-react-props=\"{}\"><p>SSR</p></div>", html
    end
  end
end
