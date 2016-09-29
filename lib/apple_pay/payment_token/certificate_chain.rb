module ApplePay
  class PaymentToken
    class CertificateChain
      CHAIN_OIDS = {
        leaf: '1.2.840.113635.100.6.29',
        intermediate: '1.2.840.113635.100.6.2.14'
      }

      attr_accessor :pkcs7, :leaf, :intermediate, :root

      def initialize(pkcs7_encoded)
        self.pkcs7 = OpenSSL::PKCS7.new Base64.decode64(pkcs7_encoded)
        [:leaf, :intermediate].each do |position|
          detected = pkcs7.certificates.detect do |cert|
            cert.extensions.collect(&:oid).include? CHAIN_OIDS[position]
          end
          self.send "#{position}=", detected
        end
        self.root = OpenSSL::X509::Certificate.new(
          File.read File.join(__dir__, 'AppleRootCa-G3.cer')
        )
      end

      def verify(signature_base_string)
        trusted_store = OpenSSL::X509::Store.new
        trusted_store.add_cert root
        pkcs7.certificates = [leaf, intermediate].compact
        pkcs7.verify nil, trusted_store, signature_base_string
      end
    end
  end
end
