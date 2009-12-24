class HTTPClient

  def do_get_block_with_samuel(req, proxy, conn, &block)
    Samuel.log_request(self, req) do
      do_get_block_without_samuel(req, proxy, conn, &block)
      message = conn.instance_variable_get(:@queue).pop
      conn.instance_variable_get(:@queue).push(message)
      message
    end
  end
  alias_method :do_get_block_without_samuel, :do_get_block
  alias_method :do_get_block, :do_get_block_with_samuel

end