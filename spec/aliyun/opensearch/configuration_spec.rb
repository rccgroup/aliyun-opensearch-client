require 'spec_helper'

RSpec.describe Aliyun::Opensearch::Configuration do
  describe "opensearch_url" do
    it '补全协议头' do
      described_class.endpoint = 'github.com'

      expect(described_class.opensearch_url).to eq 'https://github.com'
    end

    it '已存在协议头则不补全' do
      described_class.endpoint = 'http://github.com'

      expect(described_class.opensearch_url).to eq 'http://github.com'
    end
  end
end
