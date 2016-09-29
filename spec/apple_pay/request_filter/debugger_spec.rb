require 'spec_helper'

describe ApplePay::RequestFilter::Debugger do
  let(:endpoint) { 'https://apple-pay-gateway-cert.apple.com/paymentservices/startSession' }
  let(:request)  { HTTP::Message.new_request(:get, URI.parse(endpoint)) }
  let(:response) { HTTP::Message.new_response({:hello => 'world'}.to_json) }
  let(:request_filter) { ApplePay::RequestFilter::Debugger.new }

  describe '#filter_request' do
    it 'should log request' do
      [
        "======= [ApplePay] API REQUEST STARTED =======",
        request.dump
      ].each do |output|
        expect(ApplePay.logger).to receive(:info).with output
      end
      request_filter.filter_request(request)
    end
  end

  describe '#filter_response' do
    it 'should log response' do
      [
        "--------------------------------------------------",
        response.dump,
        "======= [ApplePay] API REQUEST FINISHED ======="
      ].each do |output|
        expect(ApplePay.logger).to receive(:info).with output
      end
      request_filter.filter_response(request, response)
    end
  end
end
