require 'spec_helper'

describe ApplePay::Merchant do
  let(:identifier) { 'merchant.io.github.apple-pay-js' }
  let(:domain) { 'apple-pay-js.github.io' }
  let(:display_name) { 'Apple Pay JS Sample' }
  let(:merchant) do
    ApplePay::Merchant.new(
      identifier,
      domain: domain,
      display_name: display_name
    )
  end
  let(:client_cert) { OpenSSL::X509::Certificate.new }
  let(:private_key) { OpenSSL::PKey::RSA.new 2048 }
  let(:authenticated_merchant) { merchant.authenticate client_cert, private_key }

  describe '#initialize' do
    subject { merchant }

    its(:identifier) { should == identifier }
    its(:domain) { should == domain }
    its(:display_name) { should == display_name }
  end

  describe '#authenticate' do
    subject { authenticated_merchant }

    its(:client_cert) { should == client_cert }
    its(:private_key) { should == private_key }
  end

  describe '#http_client' do
    context 'when authenticated' do
      subject { authenticated_merchant.http_client }
      its(:agent_name) { should == "ApplePay Gem (v#{ApplePay::VERSION})" }

      describe 'ssl_config' do
        subject { authenticated_merchant.http_client.ssl_config }
        its(:client_cert) { should == client_cert }
        its(:client_key)  { should == private_key }
      end
    end

    context 'otherwise' do
      subject { merchant.http_client }
      its(:agent_name) { should == "ApplePay Gem (v#{ApplePay::VERSION})" }

      describe 'ssl_config' do
        subject { merchant.http_client.ssl_config }
        its(:client_cert) { should == nil }
        its(:client_key)  { should == nil }
      end
    end
  end

  describe '#start_session!' do
    let(:validation_url) { 'https://apple-pay-gateway-cert.apple.com/paymentservices/startSession' }
    it do
      session = mock_request :post, validation_url, 'merchant_session', params: {
        merchantIdentifier: authenticated_merchant.identifier,
        domainName: authenticated_merchant.domain,
        displayName: authenticated_merchant.display_name
      } do
        authenticated_merchant.start_session! validation_url
      end
      session.should be_instance_of ActiveSupport::HashWithIndifferentAccess
    end
  end
end
