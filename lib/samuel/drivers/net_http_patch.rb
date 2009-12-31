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


  def connect_with_samuel
    connect_without_samuel
  rescue Exception => response
    fake_request = Object.new
    def fake_request.path; ""; end
    def fake_request.method; "CONNECT"; end
    Samuel.record_request(self, fake_request, Time.now)
    Samuel.record_response(self, fake_request, response, Time.now)
    raise
  end
  alias_method :connect_without_samuel, :connect
  alias_method :connect, :connect_with_samuel

end
