require 'webmock/rspec'

module WebMockHelper
  def mock_request(method, endpoint, response_path, options = {})
    stub_request(method, endpoint).with(
      request_for(method, options)
    ).to_return(
      response_for(response_path, options)
    )
    if block_given?
      response = yield
      a_request(method, endpoint).with(
        request_for(method, options)
      ).should have_been_made.once
      response
    end
  end

  private

  def request_for(method, options = {})
    request = {}
    params = options.try(:[], :params) || {}
    case method
    when :post, :put
      request[:body] = params.to_json
      request[:headers] = {
        'Content-Type': 'application/json'
      }
    else
      request[:query] = params
    end
    request
  end

  def response_for(response_file, options = {})
    response = {}
    response[:body] = File.new(File.join(File.dirname(__FILE__), '../mock_json', "#{response_file}.json"))
    if options[:status]
      response[:status] = options[:status]
    end
    response
  end
end

include WebMockHelper
WebMock.disable_net_connect!
