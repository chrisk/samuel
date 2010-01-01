module Samuel
  module LogEntries

    class NetHttp < Base
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
        error_classes = %w(Exception Net::HTTPClientError Net::HTTPServerError)
        response_ancestors = @response.class.ancestors.map { |a| a.to_s }
        (error_classes & response_ancestors).any?
      end
    end
  
  end
end
