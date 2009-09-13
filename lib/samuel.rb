require "logger"
require "net/http"
require "net/https"
require "benchmark"

require "samuel/net_http"
require "samuel/request"


module Samuel
  extend self

  attr_accessor :config

  def logger=(new_logger)
    @logger = new_logger
  end

  def logger
    @logger = nil if !defined?(@logger)
    return @logger if !@logger.nil?

    if defined?(RAILS_DEFAULT_LOGGER)
      @logger = RAILS_DEFAULT_LOGGER
    else
      @logger = Logger.new(STDOUT)
    end
  end

  def log_request(http, request, &block)
    request = Request.new(http, request, block)
    request.execute_and_log!
    request.response
  end

  def with_config(options = {})
    # TODO: this isn't thread-safe
    original_config = @config.dup
    @config.merge! options
    yield
    @config = original_config
  end

  def reset_config
    @config = {:name => "HTTP", :filtered_params => []}
  end

end

Samuel.reset_config
