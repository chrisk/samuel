module Samuel
  class Request
    attr_accessor :response

    def initialize(http, request, proc)
      @http, @request, @proc = http, request, proc
      @response = nil
    end

    def log!
      milliseconds = (@seconds * 1000).round
      if @http.use_ssl?
        scheme = "https"
        port   = (@http.port == 443) ? "" : ":#{@http.port}"
      else
        scheme = "http"
        port   = (@http.port == 80) ? "" : ":#{@http.port}"
      end
      uri = "#{scheme}://#{@http.address}#{port}#{@request.path}"
      method = @request.method.to_s.upcase

      if response.is_a?(Exception)
        response_info = response.class
      else
        response_info = "[#{response.code} #{response.message}]"
      end

      if [Exception, Net::HTTPClientError, Net::HTTPServerError].any? { |c| response.is_a?(c) }
        level = Logger::WARN
      else
        level = Logger::INFO
      end

      bold_blue_on, reset = "\e[4;34;1m", "\e[0m"
      Samuel.logger.add(level, "  #{bold_blue_on}HTTP request (#{milliseconds}ms) #{response_info}#{reset}  #{method} #{uri}")
    end

    def execute!
      # If an exception is raised in the Benchmark block, it'll interrupt the
      # benchmark. Instead, use an inner block to record it as the "response"
      # for raising after the benchmark (and logging) is done.
      @seconds = Benchmark.realtime do
        begin; @response = @proc.call; rescue Exception => @response; end
      end
    end

  end
end