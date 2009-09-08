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

    # If an exception is raised in this Benchmark block, it'll interrupt the
    # benchmark. Instead, use an inner block to record it as the "response"
    # for raising after the benchmark is done.
    seconds = Benchmark.realtime do
      begin; response = yield block; rescue Exception => response; end
    end
    raise response if response.is_a?(Exception)
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
    logger.add(level, "  #{bold_blue_on}HTTP request (#{milliseconds}ms) #{response_info}#{reset}  #{method} #{uri}")

    response
  end

end
