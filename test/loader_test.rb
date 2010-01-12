require 'test_helper'

class LoaderTest < Test::Unit::TestCase

  def capture_output(code = "")
    requires = @requires.map { |lib| "require '#{lib}';" }.join(' ')
    samuel_dir = "#{File.dirname(__FILE__)}/../lib"
    `#{ruby_path} -I#{samuel_dir} -e "#{requires} #{code}" 2>&1`
  end

  context "loading Samuel" do
    setup do
      start_test_server
      @requires = ['samuel']
    end

    context "when no HTTP drivers are loaded" do
      should "automatically load Net::HTTP" do
        output = capture_output "puts defined?(Net::HTTP)"
        assert_equal "constant", output.strip
      end

      should "successfully log a Net::HTTP request" do
        output = capture_output "Net::HTTP.get(URI.parse('http://localhost:8000'))"
        assert_match %r[HTTP request], output
      end

      should "not load HTTPClient" do
        output = capture_output "puts 'good' unless defined?(HTTPClient)"
        assert_equal "good", output.strip
      end
    end

    context "when Net::HTTP is already loaded" do
      setup { @requires.unshift('net/http') }

      should "successfully log a Net::HTTP request" do
        output = capture_output "Net::HTTP.get(URI.parse('http://localhost:8000'))"
        assert_match %r[HTTP request], output
      end

      should "not load HTTPClient" do
        output = capture_output "puts 'good' unless defined?(HTTPClient)"
        assert_match "good", output.strip
      end
    end

    context "when HTTPClient is already loaded" do
      setup { @requires.unshift('rubygems', 'httpclient') }

      should "successfully log an HTTPClient request" do
        output = capture_output "HTTPClient.get('http://localhost:8000')"
        assert_match %r[HTTP request], output
      end

      should "not load Net::HTTP" do
        output = capture_output "puts 'good' unless defined?(Net::HTTP)"
        assert_match "good", output.strip
      end
    end
  end

end
