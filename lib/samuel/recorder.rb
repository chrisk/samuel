module Samuel
  module Recorder
    extend self

    def record_request(http, request, time_requested)
      @requests ||= []
      @requests.push({:request => request, :time_requested => time_requested})
    end

    def record_response(http, request, response, time_responded)
      time_requested = @requests.detect { |r| r[:request] == request }[:time_requested]
      @requests.reject! { |r| r[:request] == request }
      log_request_and_response(http, request, response, time_requested, time_responded)
    end

    private

    def log_request_and_response(http, request, response, time_started, time_ended)
      log_entry_class = case http.class.to_s
        when "Net::HTTP"  then LogEntries::NetHttp
        when "HTTPClient" then LogEntries::HttpClient
        else raise NotImplementedError
      end
      log_entry = log_entry_class.new(http, request, response, time_started, time_ended)
      log_entry.log!
    end

  end
end
