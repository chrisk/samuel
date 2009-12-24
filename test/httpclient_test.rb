require 'test_helper'

class HttpClientTest < Test::Unit::TestCase

  context "making an HTTPClient request" do
    setup    { setup_test_logger
               FakeWeb.clean_registry
               Samuel.reset_config }
    teardown { teardown_test_logger }

    context "to GET http://example.com/, responding with a 200 in 53ms" do
      setup do
        Benchmark.stubs(:realtime).yields.returns(0.053)
        HTTPClient.get("http://example.com/")
      end

      should_log_lines     1
      should_log_at_level  :info
      should_log_including "HTTP request"
      should_log_including "(53ms)"
      should_log_including "[200 OK]"
      should_log_including "GET http://example.com/"
    end

    context "with SSL" do
      setup do
        HTTPClient.get("https://www.apple.com/")
      end

      should_log_including "HTTP request"
      should_log_including "GET https://www.apple.com/"
    end

    context "that raises" do
      setup do
        begin
          HTTPClient.get("https://example.com/test")
        rescue Errno::ECONNREFUSED => @exception
        end
      end

      should_log_at_level    :warn
      should_log_including   "HTTP request"
      should_log_including   "GET https://example.com/test"
      should_log_including   "Errno::ECONNREFUSED"
      should_log_including   %r|\d+ms|
      should_raise_exception Errno::ECONNREFUSED
    end

    context "that responds with a 400-level code" do
      setup do
        HTTPClient.get("http://example.com/test")
      end

      should_log_at_level :warn
    end


  end
  
end