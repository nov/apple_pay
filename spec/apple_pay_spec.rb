require 'spec_helper'

describe ApplePay do
  after { ApplePay.debugging = false }

  it 'has a version number' do
    ApplePay::VERSION.should be_present
  end

  describe '.debug!' do
    before { ApplePay.debug! }
    its(:debugging?) { should == true }
  end

  describe '.debug' do
    it 'should enable debugging within given block' do
      ApplePay.debug do
        ApplePay.debugging?.should == true
      end
      ApplePay.debugging?.should == false
    end

    it 'should not force disable debugging' do
      ApplePay.debug!
      ApplePay.debug do
        ApplePay.debugging?.should == true
      end
      ApplePay.debugging?.should == true
    end
  end
end
