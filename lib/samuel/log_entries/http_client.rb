module Samuel
  module LogEntries

    class HttpClient < Base
      extend Forwardable

      def_delegators :"@request.header.request_uri",
                     :host, :path, :query, :scheme, :port

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
end
