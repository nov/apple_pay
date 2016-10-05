module ApplePay
  class PaymentToken
    class EncryptedData
      class DecryptionFailed < Error; end

      MERCHANT_ID_OID = '1.2.840.113635.100.6.32'

      attr_accessor :data

      def initialize(encoded_data)
        self.data = Base64.decode64 encoded_data
      end

      def decrypt!(client_cert, private_key, ephemeral_public_key_or_wrapped_key) # NOTE: Payment Processing Certificate
        merchant_id = merchant_id_in client_cert
        shared_secret = shared_secret_derived_from private_key, ephemeral_public_key_or_wrapped_key
        symmetric_key = symmetric_key_derived_from merchant_id, shared_secret
        cipher = OpenSSL::Cipher.new('aes-256-gcm')
        cipher.decrypt
        cipher.iv_len = 16 # NOTE: waiting ruby openssl update. https://github.com/ruby/ruby/pull/569
        cipher.key = symmetric_key
        cipher.auth_tag = data[-16..-1]
        cipher.update(data[0..-17]) + cipher.final
      end

      private

      def merchant_id_in(client_cert)
        merchant_id_with_prefix = client_cert.extensions.detect do |ext|
          ext.oid == MERCHANT_ID_OID
        end
        raise DecryptionFailed, 'Merchant ID missing' unless merchant_id_with_prefix
        merchant_id_with_prefix.value[2..-1]
      end

      def shared_secret_derived_from(private_key, ephemeral_public_key_or_wrapped_key)
        case private_key
        when OpenSSL::PKey::RSA
          shared_secret_derived_from_rsa(
            private_key,
            ephemeral_public_key_or_wrapped_key
          )
        when OpenSSL::PKey::EC
          shared_secret_derived_from_ec(
            private_key,
            ephemeral_public_key_or_wrapped_key
          )
        else
          raise DecryptionFailed, "Unknown algorithm (#{private_key.class})"
        end
      end

      def shared_secret_derived_from_rsa(private_key, wrapped_key)
        raise DecryptionFailed, 'RSA not supported yet'
      end

      def shared_secret_derived_from_ec(private_key, ephemeral_public_key)
        public_key = OpenSSL::PKey::EC.new(
          Base64.decode64 ephemeral_public_key
        ).public_key
        point = OpenSSL::PKey::EC::Point.new(
          private_key.group,
          public_key.to_bn
        )
        private_key.dh_compute_key point
      end

      def symmetric_key_derived_from(merchant_id, shared_secret)
        OpenSSL::Digest::SHA256.digest(
          "\x00" * 3 + "\x01" +
          shared_secret +
          "\x0D" + 'id-aes256-GCM' + 'Apple' + [merchant_id].pack("H*")
        )
      end
    end
  end
end
