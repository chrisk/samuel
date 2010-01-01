module HTTPClientPatch
  def self.included(klass)
    methods_to_wrap = %w(initialize do_get_block do_get_stream)
    methods_to_wrap.each do |method|
      klass.send(:alias_method, "#{method}_without_samuel", method)
      klass.send(:alias_method, method, "#{method}_with_samuel")
    end
  end

  def initialize_with_samuel(*args)
    initialize_without_samuel(*args)
    @request_filter << Samuel::HTTPClientLoggingFilter.new(self)
  end

  def do_get_block_with_samuel(req, proxy, conn, &block)
    begin
      do_get_block_without_samuel(req, proxy, conn, &block)
    rescue Exception => e
      Samuel.record_response(self, req, e, Time.now)
      raise
    end
  end

  def do_get_stream_with_samuel(req, proxy, conn)
    begin
      do_get_stream_without_samuel(req, proxy, conn)
    rescue Exception => e
      Samuel.record_response(self, req, e, Time.now)
      raise
    end
  end
end

module Samuel
  class HTTPClientLoggingFilter
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
end
