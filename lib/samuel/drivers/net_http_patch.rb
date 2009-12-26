class Net::HTTP

  def request_with_samuel(req, body = nil, &block)
    Samuel.log_request(self, req) do
      request_without_samuel(req, body, &block)
    end
  end
  alias_method :request_without_samuel, :request
  alias_method :request, :request_with_samuel

end
