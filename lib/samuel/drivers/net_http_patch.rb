class Net::HTTP

  def request_with_samuel(request, body = nil, &block)
    Samuel.record_request(self, request, Time.now)

    response, exception_raised = nil, false
    begin
      response = request_without_samuel(request, body, &block)
    rescue Exception => response
      exception_raised = true
    end

    Samuel.record_response(self, request, response, Time.now)

    raise response if exception_raised
    response
  end
  alias_method :request_without_samuel, :request
  alias_method :request, :request_with_samuel

end
