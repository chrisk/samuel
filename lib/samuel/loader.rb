module Samuel
  module Loader
    extend self

    def load_drivers
      loaded = { :net_http    => defined?(Net::HTTP),
                 :http_client => defined?(HTTPClient) }

      Net::HTTP.send(:include, DriverPatches::NetHTTP) if loaded[:net_http]
      HTTPClient.send(:include, DriverPatches::HTTPClient) if loaded[:http_client]

      if loaded.values.none?
        require 'net/http'
        load_drivers
      end
    end

  end
end