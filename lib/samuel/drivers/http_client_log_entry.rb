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

    def response_summary
      if @response.is_a?(Exception)
        @response.class
      else
        "[#{@response.header.status_code} #{@response.header.reason_phrase.strip}]"
      end
    end

    def error?
      @response.is_a?(Exception) || @response.status.to_s =~ /^(4|5)/
    end

  end
end
