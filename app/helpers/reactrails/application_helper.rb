module Reactrails::ApplicationHelper
  def render_component(component_name, props = {}, options = {})
    prerender = options[:prerender]

    html = ""
    # Generate HTML server side if prerender
    html = Reactrails::ReactRenderer.render(component_name, props) if prerender

    tag.div(
      html.html_safe, # rubocop:disable Rails/OutputSafety
      data: {
        react_component: component_name,
        react_props: props.to_json
      }
    )
  end
end
