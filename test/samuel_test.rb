require 'test_helper'

class SamuelTest < Test::Unit::TestCase

  context "making an HTTP request" do
    setup do
      setup_test_logger
      FakeWeb.register_uri(:get, "http://example.com/test", :status => [200, "OK"])
      Benchmark.stubs(:realtime).yields.returns(0.053)
      Net::HTTP.start("example.com") { |query| query.get("/test") }
    end

    teardown { teardown_test_logger }

    should_log_lines     1
    should_log_including "HTTP request"
    should_log_including "(53ms)"
    should_log_including "[200 OK]"
    should_log_including "GET http://example.com/test"


    context "on a non-standard port" do
      setup do
        FakeWeb.register_uri(:get, "http://example.com:8080/test", :status => [200, "OK"])
        Net::HTTP.start("example.com", 8080) { |query| query.get("/test") }
      end

      should_log_including "GET http://example.com:8080/test"
    end

    context "with SSL" do
      setup do
        FakeWeb.register_uri(:get, "https://example.com/test", :status => [200, "OK"])
        http = Net::HTTP.new("example.com", 443); http.use_ssl = true
        http.get("/test")
      end

      should_log_including "HTTP request"
      should_log_including "GET https://example.com/test"
    end

    context "with SSL on a non-standard port" do
      setup do
        FakeWeb.register_uri(:get, "https://example.com:80/test", :status => [200, "OK"])
        http = Net::HTTP.new("example.com", 80); http.use_ssl = true
        http.get("/test")
      end

      should_log_including "HTTP request"
      should_log_including "GET https://example.com:80/test"
    end
  end

end
