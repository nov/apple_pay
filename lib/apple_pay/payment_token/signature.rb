module ApplePay
  class PaymentToken
    class Signature
      class Invalid < VerificationError; end

      attr_accessor :signature, :data, :ephemeral_public_key, :transaction_id

      def initialize(signature, data:, ephemeral_public_key:, transaction_id:)
        self.signature = signature
        self.data = data
        self.ephemeral_public_key = ephemeral_public_key
        self.transaction_id = transaction_id
      end

      def verify!
        chain = CertificateChain.new signature
        signature_base_string = [
          Base64.decode64(ephemeral_public_key),
          Base64.decode64(data),
          [transaction_id].pack('H*')
        ].join
        chain.verify(
          signature_base_string
        ) or raise Invalid
      end
    end
  end
end
