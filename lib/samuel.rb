require "logger"
require "net/http"
require "net/https"
require "httpclient" # TODO handle when HTTPClient isn't available
require "benchmark"


require "samuel/net_http"
require "samuel/http_client" # TODO handle when HTTPClient isn't available
require "samuel/request"


module Samuel
  extend self

  VERSION = "0.2.1"

  attr_writer :config, :logger

  def logger
    @logger = nil if !defined?(@logger)
    return @logger if !@logger.nil?

    if defined?(RAILS_DEFAULT_LOGGER)
      @logger = RAILS_DEFAULT_LOGGER
    else
      @logger = Logger.new(STDOUT)
    end
  end

  def config
    Thread.current[:__samuel_config] ? Thread.current[:__samuel_config] : @config
  end

  def log_request(http, request, &block)
    request = Request.new(http, request, block)
    request.perform_and_log!
    request.response
  end

  def with_config(options = {})
    original_config = config.dup
    nested = !Thread.current[:__samuel_config].nil?

    Thread.current[:__samuel_config] = original_config.merge(options)
    yield
    Thread.current[:__samuel_config] = nested ? original_config : nil
  end

  def reset_config
    Thread.current[:__samuel_config] = nil
    @config = {:label => nil, :labels => {"" => "HTTP"}, :filtered_params => []}
  end

end

Samuel.reset_config
