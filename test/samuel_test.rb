require 'test_helper'

class SamuelTest < Test::Unit::TestCase

  context "Samuel" do
    setup do
      Samuel.logger = nil # reset logger
    end

    should "have a logger" do
      Samuel.logger
    end

    should "be able to have its logger changed" do
      Samuel.logger = :mock
      assert_equal :mock, Samuel.logger
    end

    should "log a basic HTTP request" do
      Net::HTTP.start("example.com") { |query| query.get('/test') }
    end
  end

end
