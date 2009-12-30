require 'test_helper'

class HttpClientTest < Test::Unit::TestCase
  context "making an HTTPClient request" do
    setup    { setup_test_logger
               start_test_server
               Samuel.reset_config }
    teardown { teardown_test_logger }

    context "to GET http://localhost:8000/, responding with a 200 in 53ms" do
      setup do
        now = Time.now
        Time.stubs(:now).returns(now, now + 0.053)
        HTTPClient.get("http://localhost:8000/")
      end

      should_log_lines     1
      should_log_at_level  :info
      should_log_including "HTTP request"
      should_log_including "(53ms)"
      should_log_including "[200 OK]"
      should_log_including "GET http://localhost:8000/"
    end

    context "using PUT" do
      setup do
        HTTPClient.put("http://localhost:8000/books/1", "test=true")
      end

      should_log_including "PUT http://localhost:8000/books/1"
    end

    context "using an asynchronous POST" do
      setup do
        body = "title=Infinite%20Jest"
        client = HTTPClient.new
        connection = client.post_async("http://localhost:8000/books", body)
        sleep 0.1 until connection.finished?
      end

      should_log_including "POST http://localhost:8000/books"
    end

    context "that raises" do
      setup do
        begin
          HTTPClient.get("http://localhost:8001/")
        rescue Errno::ECONNREFUSED => @exception
        end
      end

      should_log_at_level    :warn
      should_log_including   "HTTP request"
      should_log_including   "GET http://localhost:8001/"
      should_log_including   "Errno::ECONNREFUSED"
      should_log_including   %r|\d+ms|
      should_raise_exception Errno::ECONNREFUSED
    end

    context "using an asynchronous GET that raises" do
      setup do
        begin
          client = HTTPClient.new
          connection = client.get_async("http://localhost:8001/")
          sleep 0.1 until connection.finished?
        rescue Errno::ECONNREFUSED => @exception
        end
      end

      should_log_at_level    :warn
      should_log_including   "HTTP request"
      should_log_including   "GET http://localhost:8001/"
      should_log_including   "Errno::ECONNREFUSED"
      should_log_including   %r|\d+ms|
      should_raise_exception Errno::ECONNREFUSED
    end

    context "that responds with a 400-level code" do
      setup do
        HTTPClient.get("http://localhost:8000/test?404")
      end

      should_log_at_level :warn
      should_log_including "[404 Not Found]"
    end

    context "that responds with a 500-level code" do
      setup do
        HTTPClient.get("http://localhost:8000/test?500")
      end

      should_log_at_level :warn
      should_log_including "[500 Internal Server Error]"
    end
  end

end
