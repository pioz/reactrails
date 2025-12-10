require "rails/generators/base"
require "json"

class Reactrails::InstallGenerator < Rails::Generators::Base
  desc "Install ReactRails integration"

  def add_react_loader_tag_to_layout
    layout_path = "app/views/layouts/application.html.erb"
    insert_line = '<%= javascript_include_tag "react_loader", "data-turbo-track": "reload", type: "module" %>'
    anchor_line = '<%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>'

    unless File.exist?(layout_path)
      say_status :warning, "Layout file not found: #{layout_path}", :yellow
      return
    end

    content = File.read(layout_path)

    if content.include?(insert_line)
      say_status :info, "React loader tag already present in layout", :blue
      return
    end

    anchor_regex = /(.*)#{Regexp.escape(anchor_line)}/
    match = content.match(anchor_regex)

    unless match
      say_status :warning, "Anchor line for application javascript tag not found in layout", :yellow
      return
    end

    indentation = match[1]
    new_content = content.sub(anchor_line, "#{insert_line}\n#{indentation}#{anchor_line}")

    File.write(layout_path, new_content)
    say_status :insert, "Added react_loader javascript_include_tag to layout with proper indentation", :green
  end

  def add_build_ssr_script_to_package_json
    package_json_path = "package.json"
    script_name = "build:ssr"
    script_command = "esbuild app/javascript/components/index.js --bundle --sourcemap --format=esm --outdir=app/assets/builds/ssr --platform=browser --format=iife --define:process.env.NODE_ENV=\\\"production\\\""

    unless File.exist?(package_json_path)
      say_status :warning, "package.json not found", :yellow
      return
    end

    json = JSON.parse(File.read(package_json_path))
    json["scripts"] ||= {}
    scripts = json["scripts"]

    if scripts.key?(script_name)
      say_status :info, "Script #{script_name} already present in package.json", :blue
      return
    end

    new_scripts = {}
    inserted = false

    if scripts.any?
      scripts.each do |key, value|
        new_scripts[key] = value
        if key == "build"
          new_scripts[script_name] = script_command
          inserted = true
        end
      end
    end

    unless inserted
      new_scripts = scripts.dup if new_scripts.empty? && scripts.any?
      new_scripts[script_name] = script_command
    end

    json["scripts"] = new_scripts

    File.write(package_json_path, "#{JSON.pretty_generate(json)}\n")
    say_status :insert, "Added #{script_name} to package.json scripts", :green
  rescue JSON::ParserError
    say_status :error, "package.json is not valid JSON", :red
  end

  def add_ssr_process_to_procfile
    procfile_path = "Procfile.dev"
    js_line = "js: yarn build --watch"
    ssr_line = "ssr: yarn build:ssr --watch"

    unless File.exist?(procfile_path)
      say_status :warning, "Procfile.dev not found", :yellow
      return
    end

    content = File.read(procfile_path)

    if content.include?(ssr_line)
      say_status :info, "ssr process already present in Procfile.dev", :blue
      return
    end

    unless content.include?(js_line)
      say_status :warning, "Anchor line yarn build not found in Procfile.dev", :yellow
      return
    end

    new_content = content.sub(js_line, "#{js_line}\n#{ssr_line}")
    File.write(procfile_path, new_content)
    say_status :insert, "Added ssr process under js process in Procfile.dev", :green
  end

  def add_app_components_index
    index_js_path = "app/javascript/components/index.js"
    if File.exist?(index_js_path)
      say_status :info, "#{index_js_path} already present", :blue
      return
    end

    new_content = <<~FILE
      // Global registry for React components.
      // You can extend this object or generate it automatically.
      globalThis.ReactRailsComponents = {}
    FILE
    File.write(index_js_path, new_content)
    say_status :insert, "Added #{index_js_path}", :green
  end

  def add_initializer
    initializer_path = "config/initializers/reactrails.rb"
    if File.exist?(initializer_path)
      say_status :info, "#{initializer_path} already present", :blue
      return
    end

    new_content = <<~FILE
      Reactrails.configure do |config|
        # Move SSR app registry bundle to a custom folder
        # config.app_registry_bundle_path = Rails.root.join("app/assets/builds/ssr/index.js")

        # Preload JS code to run
        # config.ssr_preload_code = nil
      end
    FILE
    File.write(initializer_path, new_content)
    say_status :insert, "Added #{initializer_path}", :green
  end
end
