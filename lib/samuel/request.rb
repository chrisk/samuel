module Samuel
  class Request

    attr_accessor :response

    def initialize(http, request, proc)
      @http, @request, @proc = http, request, proc
    end

    def perform_and_log!
      # If an exception is raised in the Benchmark block, it'll interrupt the
      # benchmark. Instead, use an inner block to record it as the "response"
      # for raising after the benchmark (and logging) is done.
      @seconds = Benchmark.realtime do
        begin; @response = @proc.call; rescue Exception => @response; end
      end
      Samuel.logger.add(log_level, log_message)
      raise @response if @response.is_a?(Exception)
    end

    private

    def address
      case @http
      when Net::HTTP
        @http.address
      when HTTPClient
        @request.header.request_uri.host
      else
        raise "Unhandled HTTP driver"
      end
    end

    def log_message
      bold      = "\e[1m"
      blue      = "\e[34m"
      underline = "\e[4m"
      reset     = "\e[0m"
      "  #{bold}#{blue}#{underline}#{label} request (#{milliseconds}ms) " +
      "#{response_summary}#{reset}  #{method} #{uri}"
    end

    def milliseconds
      (@seconds * 1000).round
    end

    def uri
      "#{scheme}://#{address}#{port_if_not_default}#{path}#{'?' if query}#{filtered_query}"
    end

    def path
      case @request
      when Net::HTTPRequest
        @request.path.split("?")[0]
      when HTTP::Message
        @request.header.request_uri.path
      else
        raise "Unhandled HTTP driver"
      end
    end
    
    def query
      case @request
      when Net::HTTPRequest
        @request.path.split("?")[1]
      when HTTP::Message
        @request.header.request_uri.query
      else
        raise "Unhandled HTTP driver"
      end
    end

    def filtered_query
      return "" if query.nil?
      patterns = [Samuel.config[:filtered_params]].flatten
      patterns.map { |pattern|
        pattern_for_regex = Regexp.escape(pattern.to_s)
        [/([^&]*#{pattern_for_regex}[^&=]*)=(?:[^&]+)/, '\1=[FILTERED]']
      }.inject(query) { |filtered, filter| filtered.gsub(*filter) }
    end

    def scheme
      if @http.is_a?(Net::HTTP)
        @http.use_ssl? ? "https" : "http"
      else
        @request.header.request_uri.scheme
      end
    end

    def ssl?
      scheme == 'https'
    end

    def port
      if @http.is_a?(Net::HTTP)
        @http.port
      else
        @request.header.request_uri.port
      end
    end

    def port_if_not_default
      if (!ssl? && port == 80) || (ssl? && port == 443)
        ""
      else
        ":#{port}"
      end
    end

    def method
      case @request
      when Net::HTTPRequest
        @request.method.to_s.upcase
      when HTTP::Message
        @request.header.request_method
      else
        raise "Unhandled HTTP driver"
      end
    end

    def label
      return Samuel.config[:label] if Samuel.config[:label]

      pair = Samuel.config[:labels].detect { |domain, label| address.include?(domain) }
      pair[1] if pair
    end

    def response_summary
      case response
      when Exception
        response.class
      when Net::HTTPResponse
        "[#{response.code} #{response.message}]"
      when HTTP::Message
        "[#{response.header.status_code} #{response.header.reason_phrase}]"
      else
        raise "Unhandled HTTP driver"
      end
    end

    def log_level
      case response
      when Exception, Net::HTTPClientError, Net::HTTPServerError
        Logger::WARN
      when HTTP::Message
        response.status.to_s =~ /^(4|5)/ ? Logger::WARN : Logger::INFO
      else
        Logger::INFO
      end
    end

  end
end
