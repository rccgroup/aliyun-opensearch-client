require 'spec_helper'

RSpec.describe Aliyun::Opensearch::ClientExt::Traffic::Header do
  describe "initialize" do
    it '初始化, 验证参数' do
      header = described_class.new('GET', '/a/b/c', api_params: {a:1}, access_key_id: 'abc', access_key_secret: "def")

      expect(header.instance_variable_get("@request_method")).to eq 'GET'
      expect(header.instance_variable_get("@path")).to eq '/a/b/c'
      expect(header.instance_variable_get("@api_params")).to eq({a:1})
      expect(header.instance_variable_get("@access_key_id")).to eq 'abc'
      expect(header.instance_variable_get("@access_key_secret")).to eq "def"
    end

    it '初始化, ak根据config取值' do
      Aliyun::Opensearch::Configuration.access_key_id = 'abc'
      Aliyun::Opensearch::Configuration.access_key_secret = "def"

      header = described_class.new('GET', '/a/b/c')

      expect(header.instance_variable_get("@access_key_id")).to eq 'abc'
      expect(header.instance_variable_get("@access_key_secret")).to eq "def"
    end

    it '初始化, request_method转大写' do
      header = described_class.new(:post, '/a/b/c')

      expect(header.instance_variable_get("@request_method")).to eq 'POST'
    end

    it '初始化, 参数优先于config' do
      Aliyun::Opensearch::Configuration.access_key_id = 'abc'
      Aliyun::Opensearch::Configuration.access_key_secret = "def"

      header = described_class.new('GET', '/a/b/c', access_key_id: 'abc2', access_key_secret: "def2")

      expect(header.instance_variable_get("@access_key_id")).to eq 'abc2'
      expect(header.instance_variable_get("@access_key_secret")).to eq "def2"
    end
  end

  describe "generate" do
    it '生成Header' do
      header = described_class.new(:post, '/a/b/c')

      allow(header).to receive(:content_type).and_return('1')
      allow(header).to receive(:date).and_return('2')
      allow(header).to receive(:content_md5).and_return('3')
      allow(header).to receive(:x_opensearch_headers).and_return({'X-Opensearch-Test' => '4'})
      allow(header).to receive(:authorization).and_return('5')

      expect(header.generate).to eq({
        'User-Agent' => described_class::DEFAULT_UA,
        'Content-Type' => '1',
        'Date' => '2',
        'Content-Md5' => '3',
        'X-Opensearch-Test' => '4',
        'Authorization' => '5',
      })
    end
  end

  describe "x_opensearch_headers" do
    it '返回X-Opensearch开头的Header' do
      header = described_class.new(:post, '/a/b/c')
      allow(header).to receive(:x_opensearch_nonce).and_return('Test')

      expect(header.x_opensearch_headers).to eq({
        'X-Opensearch-Nonce' => 'Test'
      })
    end
  end

  describe "content_type" do
    it '返回content_type' do
      header = described_class.new(:post, '/a/b/c')

      expect(header.content_type).to eq(described_class::DEFAULT_CONTENT_TYPE)
    end
  end

  describe "x_opensearch_nonce" do
    it '根据当前时间返回Nonce, 最后6位为随机数' do
      travel_to(Time.parse('2022-07-08')) do
        # 重复运行保证随机数范围正确
        30.times do
          header = described_class.new(:post, '/a/b/c')

          expect(header.x_opensearch_nonce[...10].to_i).to eq(Time.now.to_i)
          expect(header.x_opensearch_nonce[10..16].to_i).to be_between(described_class::NONCE_SUFFIX_MIN, described_class::NONCE_SUFFIX_MAX)
        end
      end
    end
  end

  describe "date" do
    it '返回UTC时间的日期格式化' do
      travel_to(Time.parse('2022-07-08')) do
        header = described_class.new(:post, '/a/b/c')
        expect(header.date).to eq Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      end
    end
  end

  describe "content_md5" do
    it '参数不存在时返回nil' do
      header = described_class.new(:post, '/a/b/c')
      expect(header.content_md5).to be nil
    end

    it 'get请求时返回nil' do
      header = described_class.new(:get, '/a/b/c', api_params: {a:1})
      expect(header.content_md5).to be nil
    end

    it 'post请求有参数时, 返回md5后的结果' do
      api_params = { "a" => 1 }
      header = described_class.new(:post, '/a/b/c', api_params: api_params)
      allow(Digest::MD5).to receive(:hexdigest).with(api_params.to_json).and_return('123')
      expect(header.content_md5).to eq '123'
    end
  end
end
