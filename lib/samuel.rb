require "logger"
require "net/http"
require "net/https"
require "benchmark"

require "samuel/net_http"

module Samuel
  extend self

  def logger=(new_logger)
    @logger = new_logger
  end

  def logger
    return @logger if !@logger.nil?

    @logger = 
      if defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      else
        Logger.new(STDOUT)
      end
  end

  def log_request(http, request, &block)
    response, seconds = nil, 0

    begin
      seconds = Benchmark.realtime { response = yield block }
    ensure
      milliseconds = (seconds * 1000).round
      if http.use_ssl?
        scheme = "https"
        port   = (http.port == 443) ? "" : ":#{http.port}"
      else
        scheme = "http"
        port   = (http.port == 80) ? "" : ":#{http.port}"
      end
      uri = "#{scheme}://#{http.address}#{port}#{request.path}"

      method = request.method.to_s.upcase
      bold_blue_on, reset = "\e[4;34;1m", "\e[0m"

      level = Logger::INFO
      level = Logger::WARN if response.is_a?(Net::HTTPClientError) || response.is_a?(Net::HTTPServerError)
      logger.add(level, "  #{bold_blue_on}HTTP request (#{milliseconds}ms) [#{response.code} #{response.message}]#{reset}  #{method} #{uri}")
    end
    response
  end
end
