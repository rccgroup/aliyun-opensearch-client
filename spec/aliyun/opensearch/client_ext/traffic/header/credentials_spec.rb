require 'spec_helper'

RSpec.describe Aliyun::Opensearch::ClientExt::Traffic::Header do
  describe "authorization" do
    it '生成authorization的信息' do
      header = described_class.new('GET', '/a/b/c', access_key_id: 'abcdef')
      allow(header).to receive(:signature).and_return('zyxwvu')
      expect(header.authorization).to eq 'OPENSEARCH abcdef:zyxwvu'
    end
  end

  describe "signature" do
    it '生成signature的信息' do
      header = described_class.new('GET', '/a/b/c', access_key_id: 'abcdef', access_key_secret: 'uvwxyz')

      allow(header).to receive(:content_md5).and_return('1')
      allow(header).to receive(:content_type).and_return('2')
      allow(header).to receive(:date).and_return('3')
      allow(header).to receive(:canonicalized_open_search_headers).and_return('4')
      allow(header).to receive(:canonicalized_resource).and_return('5')

      allow(OpenSSL::HMAC).to receive(:digest).with(OpenSSL::Digest.new('sha1'), 'uvwxyz', "GET\n1\n2\n3\n4\n5").and_return('hmac')
      allow(Base64).to receive(:encode64).with('hmac').and_return('best_sign')

      expect(header.signature).to eq 'best_sign'
    end
  end

  describe "canonicalized_open_search_headers" do
    it '将Header中X-Opensearch-*的key变为小写并返回' do
      header = described_class.new('GET', '/a/b/c')
      allow(header).to receive(:x_opensearch_headers).and_return({
        'X-Opensearch-Test' => '123'
      })
      expect(header.canonicalized_open_search_headers).to eq 'x-opensearch-test:123'
    end

    it 'Header中有多个X-Opensearch-*的key时, 按照key字母顺序排序并拼接换行符返回' do
      header = described_class.new('GET', '/a/b/c')
      allow(header).to receive(:x_opensearch_headers).and_return({
        'X-Opensearch-Zcase' => '123',
        'X-Opensearch-Acase' => '456',
      })
      expect(header.canonicalized_open_search_headers).to eq "x-opensearch-acase:456\nx-opensearch-zcase:123"
    end
  end

  describe "canonicalized_resource" do
    it 'GET请求, api_params为空, 只返回path' do
      header = described_class.new('GET', '/a/b/c')
      expect(header.canonicalized_resource).to eq '/a/b/c'
    end

    it 'POST请求, 只返回path' do
      header = described_class.new('POST', '/a/b/c')
      expect(header.canonicalized_resource).to eq '/a/b/c'
    end

    it 'GET请求, api_params为英文, 会按照api_params的key排序, 再拼接path返回' do
      header = described_class.new('GET', '/a/b/c', api_params: { z: '1', x: '2', y: '3' })
      expect(header.canonicalized_resource).to eq '/a/b/c?x=2&y=3&z=1'
    end

    it 'GET请求, api_params有中文, 会按照api_params的key排序, 并且将中文转换为URLCode, 再拼接path返回' do
      header = described_class.new('GET', '/a/b/c', api_params: { z: '一', x: '二', y: '三' })
      expect(header.canonicalized_resource).to eq '/a/b/c?x=%E4%BA%8C&y=%E4%B8%89&z=%E4%B8%80'
    end
  end
end
