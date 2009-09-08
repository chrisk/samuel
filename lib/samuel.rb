require "logger"
require "net/http"
require "net/https"
require "benchmark"

require "samuel/net_http"
require "samuel/request"


module Samuel
  extend self

  def logger=(new_logger)
    @logger = new_logger
  end

  def logger
    return @logger if !@logger.nil?

    if defined?(RAILS_DEFAULT_LOGGER)
      @logger = RAILS_DEFAULT_LOGGER
    else
      @logger = Logger.new(STDOUT)
    end
  end

  def log_request(http, request, &block)
    Request.new(http, request, &block)
  end

end
