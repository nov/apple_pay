module ApplePay
  class PaymentToken
    attr_accessor :token

    def initialize(token)
      self.token = token.with_indifferent_access
    end

    def verify!
      Signature.new(
        token[:paymentData][:signature],
        data: token[:paymentData][:data],
        ephemeral_public_key: token[:paymentData][:header][:ephemeralPublicKey],
        transaction_id: token[:paymentData][:header][:transactionId],
        application_data: token[:paymentData][:header][:applicationData]
      ).verify!
      self
    end

    def decrypt!(client_cert, private_key)
      decrypted = EncryptedData.new(
        token[:paymentData][:data]
      ).decrypt!(
        client_cert,
        private_key,
        token[:paymentData][:header][:ephemeralPublicKey]
      )
      JSON.parse decrypted
    end
  end
end

require 'apple_pay/payment_token/certificate_chain'
require 'apple_pay/payment_token/signature'
