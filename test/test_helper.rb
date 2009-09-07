require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'fakeweb'

FakeWeb.allow_net_connect = false

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'samuel'

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
        assert contents.include?(what)
      end
    end
  end

  def setup_test_logger
    FileUtils.rm_rf TEST_LOG_PATH
    FileUtils.touch TEST_LOG_PATH
    Samuel.logger = Logger.new(TEST_LOG_PATH)
  end

  def teardown_test_logger
    FileUtils.rm_rf TEST_LOG_PATH
  end
end
