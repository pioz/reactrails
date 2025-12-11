module Reactrails::ApplicationHelper
  def render_component(component_name, props = {}, options = {})
    prerender = options[:prerender]
    tag_name = options[:tag] || :div
    html_options = options[:html_options] || {}

    html_options[:data] ||= {}
    html_options[:data][:react_component] = component_name
    html_options[:data][:react_props] = props.to_json

    raise ArgumentError, "Invalid tag name: #{tag_name.inspect}" unless tag.respond_to?(tag_name)

    html = ""
    # Generate HTML server side if prerender
    html = Reactrails::ReactRenderer.render(component_name, props) if prerender

    tag.public_send(
      tag_name,
      html.html_safe, # rubocop:disable Rails/OutputSafety
      **html_options
    )
  end
end
