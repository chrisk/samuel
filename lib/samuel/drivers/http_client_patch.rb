class HTTPClient

  def initialize_with_samuel(*args)
    initialize_without_samuel(*args)
    @request_filter << LoggingFilter.new(self)
  end
  alias_method :initialize_without_samuel, :initialize
  alias_method :initialize, :initialize_with_samuel

  def do_get_block_with_samuel(req, proxy, conn, &block)
    begin
      do_get_block_without_samuel(req, proxy, conn, &block)
    rescue Exception => e
      Samuel.record_response(self, req, e, Time.now)
      raise
    end
  end
  alias_method :do_get_block_without_samuel, :do_get_block
  alias_method :do_get_block, :do_get_block_with_samuel

  # TODO: record exceptions for async requests, too

end


class LoggingFilter
  def initialize(http_client_instance)
    @http_client_instance = http_client_instance
  end

  def filter_request(request)
    Samuel.record_request(@http_client_instance, request, Time.now)
  end

  def filter_response(request, response)
    Samuel.record_response(@http_client_instance, request, response, Time.now)
    nil # this returns command symbols like :retry, etc.
  end
end
