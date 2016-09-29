module ApplePay
  class Merchant
    attr_accessor :identifier, :domain, :display_name, :client_cert, :private_key

    def initialize(identifier, domain:, display_name:)
      self.identifier   = identifier
      self.domain       = domain
      self.display_name = display_name
    end

    def authenticate(client_cert, private_key)
      self.client_cert = client_cert
      self.private_key = private_key
      self
    end

    def http_client
      client = HTTPClient.new(
        agent_name: "ApplePay Gem (v#{VERSION})"
      )
      client.request_filter << RequestFilter::Debugger.new if ApplePay.debugging?
      client.ssl_config.client_cert = client_cert
      client.ssl_config.client_key  = private_key
      client
    end

    def start_session!(validation_url)
      handle_response do
        http_client.post validation_url, {
          merchantIdentifier: identifier,
          domainName: domain,
          displayName: display_name
        }.to_json, 'Content-Type': 'application/json'
      end
    end

    private

    def handle_response
      response = yield
      case response.status
      when 200..201
        JSON.parse(response.body).with_indifferent_access
      else
        raise APIError 'Start Session Failed'
      end
    end
  end
end
