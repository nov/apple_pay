module ApplePay
  class PaymentToken
    class Signature
      class VerificationFailed < Error; end

      attr_accessor :signature, :data, :ephemeral_public_key, :wrapped_key, :transaction_id, :application_data

      def initialize(signature, data:, ephemeral_public_key: nil, wrapped_key: nil, transaction_id:, application_data: nil)
        self.signature = signature
        self.data = data
        self.ephemeral_public_key = ephemeral_public_key
        self.wrapped_key = wrapped_key
        self.transaction_id = transaction_id
        self.application_data = application_data
      end

      def verify!
        chain = CertificateChain.new signature
        signature_base_string = [
          Base64.decode64(ephemeral_public_key || wrapped_key),
          Base64.decode64(data),
          [transaction_id].pack('H*'),
          [application_data].pack('H*')
        ].join
        chain.verify(
          signature_base_string
        ) or raise VerificationFailed
      end
    end
  end
end
