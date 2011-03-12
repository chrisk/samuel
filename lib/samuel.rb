require "logger"
require "forwardable"

require "samuel/loader"
require "samuel/diary"
require "samuel/driver_patches/http_client"
require "samuel/driver_patches/net_http"
require "samuel/log_entries/base"
require "samuel/log_entries/http_client"
require "samuel/log_entries/net_http"


module Samuel
  extend self

  VERSION = "0.3.2"

  attr_writer :logger, :config

  def logger
    @logger = nil if !defined?(@logger)
    return @logger if !@logger.nil?

    @logger = case
      when defined?(Rails) && Rails.respond_to?('logger')
        Rails.logger
      when defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      else
        Logger.new(STDOUT)
    end
  end

  def config
    Thread.current[:__samuel_config] ? Thread.current[:__samuel_config] : @config
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
    @config = {:label => nil, :labels => {}, :filtered_params => []}
  end
end


Samuel.reset_config
Samuel::Loader.apply_driver_patches
