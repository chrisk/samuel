require "logger"
require "forwardable"

require "samuel/driver_patches/http_client"
require "samuel/driver_patches/net_http"
require "samuel/log_entries/base"
require "samuel/log_entries/http_client"
require "samuel/log_entries/net_http"


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

  def log_request_and_response(http, request, response, time_started, time_ended)
    log_entry_class = case http.class.to_s
      when "Net::HTTP"  then LogEntries::NetHttp
      when "HTTPClient" then LogEntries::HttpClient
      else raise NotImplementedError
    end
    log_entry = log_entry_class.new(http, request, response, time_started, time_ended)
    log_entry.log!
  end

  def record_request(http, request, time_requested)
    @requests ||= []
    @requests.push({:request => request, :time_requested => time_requested})
  end

  def record_response(http, request, response, time_responded)
    time_requested = @requests.detect { |r| r[:request] == request }[:time_requested]
    Samuel.log_request_and_response(http, request, response, time_requested, time_responded)
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

  def load_drivers
    driver_loaded = false

    if defined?(Net::HTTP)
      Net::HTTP.send(:include, DriverPatches::NetHTTP)
      driver_loaded = true
    end

    if defined?(HTTPClient)
      HTTPClient.send(:include, DriverPatches::HTTPClient)
      driver_loaded = true
    end

    if !driver_loaded
      require 'net/http'
      load_drivers
    end
  end

end

Samuel.reset_config
Samuel.load_drivers
