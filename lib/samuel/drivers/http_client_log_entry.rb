module Samuel
  class HttpClientLogEntry < LogEntry

    def host
      @request.header.request_uri.host
    end

    def path
      @request.header.request_uri.path
    end

    def query
      @request.header.request_uri.query
    end

    def scheme
      @request.header.request_uri.scheme
    end

    def port
      @request.header.request_uri.port
    end

    def method
      @request.header.request_method
    end

    def status_code
      @response.status
    end

    def status_message
      @response.header.reason_phrase.strip
    end

    def error?
      @response.is_a?(Exception) || @response.status.to_s =~ /^(4|5)/
    end

  end
end
