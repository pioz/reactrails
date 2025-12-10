module Reactrails
  module ApplicationHelper
    def render_component(componentName, props = {}, options = {})
      prerender = options[:prerender]

      html = ""
      # Generate HTML server side if prerender
      html = Reactrails::ReactRenderer.render(componentName, props) if prerender

      tag.div(
        html.html_safe,
        data: {
          react_component: componentName,
          react_props: props.to_json
        }
      )
    end
  end
end
