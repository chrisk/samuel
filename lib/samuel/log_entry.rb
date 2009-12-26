module Samuel
  class LogEntry

    attr_reader :response

    def initialize(http_driver_object, request, proc)
      @http, @request, @proc = http_driver_object, request, proc
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

    def host;   raise NotImplementedError; end
    def path;   raise NotImplementedError; end
    def query;  raise NotImplementedError; end
    def scheme; raise NotImplementedError; end
    def port;   raise NotImplementedError; end
    def method; raise NotImplementedError; end
    def response_summary; raise NotImplementedError; end
    def log_level; raise NotImplementedError; end

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
      "#{scheme}://#{host}#{port_if_not_default}#{path}#{'?' if query}#{filtered_query}"
    end

    def label
      return Samuel.config[:label] if Samuel.config[:label]

      pair = Samuel.config[:labels].detect { |domain, label| host.include?(domain) }
      pair[1] if pair
    end


    private

    def ssl?
      scheme == 'https'
    end

    def filtered_query
      return "" if query.nil?
      patterns = [Samuel.config[:filtered_params]].flatten
      patterns.map { |pattern|
        pattern_for_regex = Regexp.escape(pattern.to_s)
        [/([^&]*#{pattern_for_regex}[^&=]*)=(?:[^&]+)/, '\1=[FILTERED]']
      }.inject(query) { |filtered, filter| filtered.gsub(*filter) }
    end

    def port_if_not_default
      if (!ssl? && port == 80) || (ssl? && port == 443)
        ""
      else
        ":#{port}"
      end
    end

  end
end