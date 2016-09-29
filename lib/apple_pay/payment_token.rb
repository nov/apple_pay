module ApplePay
  class PaymentToken
    attr_accessor :token

    class VerificationError < Error; end

    def initialize(token)
      self.token = token.with_indifferent_access
    end

    def verify!
      Signature.new(
        token[:paymentData][:signature],
        data: token[:paymentData][:data],
        ephemeral_public_key: token[:paymentData][:header][:ephemeralPublicKey],
        transaction_id: token[:paymentData][:header][:transactionId]
      ).verify!
    end
  end
end

require 'apple_pay/payment_token/certificate_chain'
require 'apple_pay/payment_token/signature'
