require 'test_helper'

class RequestTest < Test::Unit::TestCase

  context "making an HTTP request" do
    setup    { setup_test_logger
               FakeWeb.clean_registry
               Samuel.reset_config }
    teardown { teardown_test_logger }

    context "to GET http://example.com/test, responding with a 200 in 53ms" do
      setup do
        FakeWeb.register_uri(:get, "http://example.com/test", :status => [200, "OK"])
        Benchmark.stubs(:realtime).yields.returns(0.053)
        open "http://example.com/test"
      end

      should_log_lines     1
      should_log_at_level  :info
      should_log_including "HTTP request"
      should_log_including "(53ms)"
      should_log_including "[200 OK]"
      should_log_including "GET http://example.com/test"
    end

    context "on a non-standard port" do
      setup do
        FakeWeb.register_uri(:get, "http://example.com:8080/test", :status => [200, "OK"])
        open "http://example.com:8080/test"
      end

      should_log_including "GET http://example.com:8080/test"
    end

    context "with SSL" do
      setup do
        FakeWeb.register_uri(:get, "https://example.com/test", :status => [200, "OK"])
        open "https://example.com/test"
      end

      should_log_including "HTTP request"
      should_log_including "GET https://example.com/test"
    end

    context "with SSL on a non-standard port" do
      setup do
        FakeWeb.register_uri(:get, "https://example.com:80/test", :status => [200, "OK"])
        open "https://example.com:80/test"
      end

      should_log_including "HTTP request"
      should_log_including "GET https://example.com:80/test"
    end

    context "that raises" do
      setup do
        FakeWeb.register_uri(:get, "http://example.com/test", :exception => Errno::ECONNREFUSED)
        begin
          Net::HTTP.start("example.com") { |http| http.get("/test") }
        rescue Errno::ECONNREFUSED => @exception
        end
      end

      should_log_at_level    :warn
      should_log_including   "HTTP request"
      should_log_including   "GET http://example.com/test"
      should_log_including   "Errno::ECONNREFUSED"
      should_log_including   %r|\d+ms|
      should_raise_exception Errno::ECONNREFUSED
    end

    context "that responds with a 500-level code" do
      setup do
        FakeWeb.register_uri(:get, "http://example.com/test", :status => [502, "Bad Gateway"])
        Net::HTTP.start("example.com") { |http| http.get("/test") }
      end

      should_log_at_level :warn
    end

    context "that responds with a 400-level code" do
      setup do
        FakeWeb.register_uri(:get, "http://example.com/test", :status => [404, "Not Found"])
        Net::HTTP.start("example.com") { |http| http.get("/test") }
      end

      should_log_at_level :warn
    end

    context "inside a configuration block with :name => 'Example'" do
      setup do
        FakeWeb.register_uri(:get, "http://example.com/test", :status => [200, "OK"])
        Samuel.with_config :name => "Example" do
          open "http://example.com/test"
        end
      end

      should_log_including "Example request"
    end
  end

end
