require 'rubygems'
require 'bundler'
Bundler.setup

require 'shoulda'
require 'mocha'

require 'net/http'
require 'httpclient'

require 'open-uri'
require 'fakeweb'
require 'webrick'

require 'samuel'

FakeWeb.allow_net_connect = false

class Test::Unit::TestCase
  TEST_LOG_PATH = File.join(File.dirname(__FILE__), 'test.log')

  def self.should_log_lines(expected_count)
    should "log #{expected_count} line#{'s' unless expected_count == 1}" do
      lines = File.readlines(TEST_LOG_PATH)
      assert_equal expected_count, lines.length
    end
  end

  def self.should_log_including(what)
    should "log a line including #{what.inspect}" do
      contents = File.read(TEST_LOG_PATH)
      if what.is_a?(Regexp)
        assert_match what, contents
      else
        assert contents.include?(what),
               "Expected #{contents.inspect} to include #{what.inspect}"
      end
    end
  end

  def self.should_log_at_level(level)
    level = level.to_s.upcase
    should "log at the #{level} level" do
      assert File.read(TEST_LOG_PATH).include?("  #{level} -- :")
    end
  end

  def self.should_raise_exception(klass)
    should "raise an #{klass} exception" do
      @exception = nil if !defined?(@exception)
      assert @exception.is_a?(klass)
    end
  end

  def self.should_have_config_afterwards_including(config)
    config.each_pair do |key, value|
      should "continue afterwards with Samuel.config[#{key.inspect}] set to #{value.inspect}" do
        assert_equal value, Samuel.config[key]
      end
    end
  end

  # The path to the current ruby interpreter. Adapted from Rake's FileUtils.
  def ruby_path
    ext = ((RbConfig::CONFIG['ruby_install_name'] =~ /\.(com|cmd|exe|bat|rb|sh)$/) ? "" : RbConfig::CONFIG['EXEEXT'])
    File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'] + ext).sub(/.*\s.*/m, '"\&"')
  end

  def setup_test_logger
    FileUtils.rm_rf TEST_LOG_PATH
    FileUtils.touch TEST_LOG_PATH
    Samuel.logger = Logger.new(TEST_LOG_PATH)
  end

  def teardown_test_logger
    FileUtils.rm_rf TEST_LOG_PATH
  end

  def start_test_server
    return if defined?(@@server)

    @@server = WEBrick::HTTPServer.new(
      :Port => 8000, :AccessLog => [],
      :Logger => WEBrick::Log.new(nil, WEBrick::BasicLog::WARN)
    )
    @@server.mount "/", ResponseCodeServer
    at_exit { @@server.shutdown }
    Thread.new { @@server.start }
  end
end

class ResponseCodeServer < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    response_code = request.query_string.nil? ? 200 : request.query_string.to_i
    response.status = response_code
  end
  alias_method :do_POST,   :do_GET
  alias_method :do_PUT,    :do_GET
  alias_method :do_DELETE, :do_GET
end
