require "test_helper"
require "minitest/mock"

class NodeRunnerTest < ActiveSupport::TestCase
  test "raises if call is invoked before compile" do
    node_binary_path = begin
      NodeRunner.find_node_binary
    rescue NodeRunner::NodeError
      skip "Node.js not available on this system"
    end
    runner = NodeRunner.new(node_binary_path: node_binary_path)

    error = assert_raises(NodeRunner::NodeError) do
      runner.call("someFunction")
    end

    assert_equal "No JS bundle compiled. Call #compile first.", error.message
  end

  test "raises if call is invoked with not found function" do
    node_binary_path = begin
      NodeRunner.find_node_binary
    rescue NodeRunner::NodeError
      skip "Node.js not available on this system"
    end
    runner = NodeRunner.new(node_binary_path: node_binary_path).compile("/* fake bundle */")

    error = assert_raises(NodeRunner::NodeError) do
      runner.call("someFunction")
    end

    assert_equal "Function someFunction is not defined in JS bundle", error.message
  end

  test "raises if node is not found" do
    File.stub(:executable?, false) do
      error = assert_raises(NodeRunner::NodeError) do
        NodeRunner.find_node_binary
      end

      assert_equal "Node.js executable not found. Please install Node or set ENV['NODE_BINARY_PATH'] to a valid executable path.", error.message
    end
  end

  test "raises when Node execution fails or stdout is empty" do
    runner = NodeRunner.new(node_binary_path: "node").compile("/* fake bundle */")

    # Simulate Node failure: non-zero exit status and empty stdout
    status = Minitest::Mock.new
    status.expect(:success?, false)

    Open3.stub(:capture3, ["", "boom stderr", status]) do
      error = assert_raises(NodeRunner::NodeError) do
        runner.call("someFunction", 1, 2)
      end

      assert_match "Node execution failed: boom stderr", error.message
    end

    status.verify
  end

  test "raises when Node output is not valid JSON" do
    runner = NodeRunner.new(node_binary_path: "node").compile("/* fake bundle */")

    status = Minitest::Mock.new
    status.expect(:success?, true)

    # stdout contains invalid JSON
    stdout = "NOT JSON"
    stderr = ""

    Open3.stub(:capture3, [stdout, stderr, status]) do
      error = assert_raises(NodeRunner::NodeError) do
        runner.call("someFunction", 1, 2)
      end

      assert_match "Failed to parse Node output:", error.message
      assert_includes error.message, "NOT JSON"
    end

    status.verify
  end

  test "raises when Node returns ok: false with error and stack" do
    runner = NodeRunner.new(node_binary_path: "node").compile("/* fake bundle */")

    status = Minitest::Mock.new
    status.expect(:success?, true)

    payload = <<~JSON.strip
      {"ok":false,"error":"Boom error","stack":"fake stack trace"}
    JSON

    Open3.stub(:capture3, [payload, "", status]) do
      error = assert_raises(NodeRunner::NodeError) do
        runner.call("someFunction", 1, 2)
      end

      # Message should include both error and stack, separated by newline
      assert_equal "Boom error\nfake stack trace", error.message
    end

    status.verify
  end

  test "raises when compile error" do
    node_binary_path = begin
      NodeRunner.find_node_binary
    rescue NodeRunner::NodeError
      skip "Node.js not available on this system"
    end

    runner = NodeRunner.new(node_binary_path: node_binary_path).compile("invalid js")

    error = assert_raises(NodeRunner::NodeError) do
      runner.call("someFunction", 1, 2)
    end

    assert_includes error.message, "Node execution failed: [stdin]:1"
  end

  test "successfully calls a JS function through Node" do
    node_binary_path = begin
      NodeRunner.find_node_binary
    rescue NodeRunner::NodeError
      skip "Node.js not available on this system"
    end

    # Simple JS bundle that exposes a function on globalThis
    js_bundle = <<~JS
      globalThis.add = (a, b) => a + b;
    JS

    runner = NodeRunner.new(node_binary_path: node_binary_path).compile(js_bundle)
    result = runner.call("add", 2, 3)

    assert_equal 5, result
  end
end
