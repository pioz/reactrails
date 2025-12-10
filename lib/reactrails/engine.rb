class Reactrails::Engine < Rails::Engine
  isolate_namespace Reactrails

  initializer "reactrails.view_helpers" do
    ActiveSupport.on_load(:action_view) do
      include Reactrails::ApplicationHelper
    end
  end

  initializer "reactrails.assets" do |app|
    app.config.assets.paths << root.join("vendor")
  end
end
