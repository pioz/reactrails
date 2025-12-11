require "open3"
require "json"

class NodeRunner
  WRAPPER_JS = <<~JS.freeze
    (async () => {
      const getTargetFunction = (name) => {
        // Try globalThis.<name>
        if (typeof globalThis !== 'undefined' && typeof globalThis[name] === 'function') {
          return globalThis[name]
        }
        // Try CommonJS exports
        if (typeof module !== 'undefined' && module.exports && typeof module.exports[name] === 'function') {
          return module.exports[name]
        }
        if (typeof exports !== 'undefined' && typeof exports[name] === 'function') {
          return exports[name]
        }
        return null
      }

      const funcName = process.env.RUN_NODE_FUNC
      const argsJson = process.env.RUN_NODE_ARGS || '[]'
      let args

      try {
        args = JSON.parse(argsJson)
      } catch (e) {
        const payload = JSON.stringify({
          ok: false,
          error: `Invalid arguments: ${e.message}`,
          stack: e.stack || null
        })
        process.stdout.write(payload)
        process.exit(0)
      }

      const fn = getTargetFunction(funcName)
      if (!fn) {
        const payload = JSON.stringify({
          ok: false,
          error: `Function ${funcName} is not defined in JS bundle`,
          stack: null
        })
        process.stdout.write(payload)
        process.exit(0)
      }

      try {
        const result = await fn.apply(null, args)
        const payload = JSON.stringify({ ok: true, result })
        process.stdout.write(payload)
      } catch (e) {
        const payload = JSON.stringify({
          ok: false,
          error: e?.message ? e.message : String(e) || 'Unknown error',
          stack: e?.stack ? e.stack : null
        })
        process.stdout.write(payload)
        process.exit(0)
      }
    })()
  JS

  class NodeError < StandardError; end

  # Detect a working Node binary.
  def self.find_node_binary
    # Use NODE_BINARY_PATH explicitly
    env_node = ENV.fetch("NODE_BINARY_PATH", "")
    return env_node if File.executable?(env_node)

    # Try `node` in PATH
    which_path = `which node`.strip
    return which_path if File.executable?(which_path)

    raise NodeError, "Node.js executable not found. Please install Node or set ENV['NODE_BINARY_PATH'] to a valid executable path."
  end

  def initialize(node_binary_path: nil)
    @node_binary_path = node_binary_path || self.class.find_node_binary
    @js_source = nil
  end

  # Stores the JS bundle source code in memory.
  # You are expected to call #compile once, then #call many times.
  def compile(js_string_bundle)
    @js_source = js_string_bundle.to_s
    self
  end

  # Calls a function defined in the JS bundle using Node.
  #
  # func   - String name of the function to call (e.g., "renderComponent")
  # params - Single argument or an Array of arguments.
  #
  # Example:
  #   ctx.call("renderComponent", ["Flash", "{\"foo\":\"bar\"}"])
  #
  def call(func, *params)
    raise NodeError, "No JS bundle compiled. Call #compile first." if @js_source.nil?

    env = {
      "RUN_NODE_FUNC" => func.to_s,
      "RUN_NODE_ARGS" => JSON.generate(params)
    }

    js_script = "#{@js_source}\n#{WRAPPER_JS}"
    stdout, stderr, status = Open3.capture3(env, @node_binary_path, stdin_data: js_script)

    # If Node exits with non-zero status we still try to parse stdout,
    # but if stdout is empty, we raise with stderr.
    raise NodeError, "Node execution failed: #{stderr}" if !status.success? || stdout.to_s.strip.empty?

    data = begin
      JSON.parse(stdout)
    rescue JSON::ParserError => e
      raise NodeError, "Failed to parse Node output: #{e.message}\nOutput was: #{stdout.inspect}"
    end

    unless data["ok"]
      msg = data["error"] || "Unknown error in Node function #{func}"
      msg = "#{msg}\n#{data['stack']}" if data["stack"]
      raise NodeError, msg
    end
    return data["result"]
  end
end
