require 'active_support'
require 'active_support/core_ext'
require 'httpclient'

module ApplePay
  VERSION = File.read(
    File.join(__dir__, '../VERSION')
  ).strip

  class Error < StandardError; end

  def self.logger
    @@logger
  end
  def self.logger=(logger)
    @@logger = logger
  end
  self.logger = ::Logger.new(STDOUT)
  self.logger.progname = 'ApplePay'

  def self.debugging?
    @@debugging
  end
  def self.debugging=(boolean)
    @@debugging = boolean
  end
  def self.debug!
    self.debugging = true
  end
  def self.debug(&block)
    original = self.debugging?
    self.debugging = true
    yield
  ensure
    self.debugging = original
  end
  self.debugging = false
end

require 'apple_pay/merchant'
require 'apple_pay/payment_token'
require 'apple_pay/request_filter/debugger'
