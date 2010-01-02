module Samuel
  module LogEntries

    class Base
      def initialize(http, request, response, time_requested, time_responded)
        @http, @request, @response = http, request, response
        @seconds = time_responded - time_requested
      end

      def log!
        Samuel.logger.add(log_level, log_message)
      end


      protected

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

        default = lambda { ["", "HTTP"] }
        Samuel.config[:labels].detect(default) { |domain, label|
          host.include?(domain)
        }[1]
      end

      def response_summary
        if @response.is_a?(Exception)
          @response.class
        else
          "[#{status_code} #{status_message}]"
        end
      end

      def log_level
        error? ? Logger::WARN : Logger::INFO
      end

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
end