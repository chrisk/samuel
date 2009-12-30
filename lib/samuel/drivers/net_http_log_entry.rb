module Samuel
  class NetHttpLogEntry < LogEntry

    def host
      @http.address
    end

    def path
      @request.path.split("?")[0]
    end

    def query
      @request.path.split("?")[1]
    end

    def scheme
      @http.use_ssl? ? "https" : "http"
    end

    def port
      @http.port
    end

    def method
      @request.method.to_s.upcase
    end

    def status_code
      @response.code
    end

    def status_message
      @response.message.strip
    end

    def error?
      error_classes = [Exception, Net::HTTPClientError, Net::HTTPServerError]
      error_classes.any? { |c| @response.is_a?(c) }
    end

  end
end
