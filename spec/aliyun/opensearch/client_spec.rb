require 'spec_helper'

RSpec.describe Aliyun::Opensearch::Client do
  let(:client) { described_class.new('test_app') }

  describe 'initialize' do
    it '初始化参数验证' do
      expect(client.instance_variable_get('@app')).to  eq 'test_app'
    end
  end

  describe 'call' do
    before do
      Aliyun::Opensearch::Configuration.endpoint = 'test.com'
      @response_body = { "status" => 'OK' }

      stub_request(:any, 'https://test.com/a/b/c').
        with(
          headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>/.+/,
          'Authorization'=>/OPENSEARCH .+:.+/,
          'Content-Type'=>'application/json',
          'Date'=>/.+/,
          'User-Agent'=>/.+/,
          'X-Opensearch-Nonce'=>/\d+/,
        }).
        to_return(status: 200, body: @response_body.to_json)
    end

    it '参数不符合抛出异常' do
      expect { client.call(:put, '/a/b/c', {a:1}) }.to raise_error(ArgumentError)
    end

    it '正常请求返回response的body' do
      get_result = client.call(:get, '/a/b/c', {})
      post_result = client.call(:post, '/a/b/c', {})

      expect(get_result).to eq @response_body
      expect(post_result).to eq @response_body
    end

    context "异常测试" do
      let (:response) do
        rsponse = double(Faraday::Response)
        allow(rsponse).to receive(:body).and_return('{"errors":[]}')
        rsponse
      end

      it '验证失败, 返回对应异常' do
        allow(client).to receive(:valid_response).and_raise(Aliyun::Opensearch::Error::AliyunService, response)
        expect { client.call(:get, '/a/b/c', {}) }.to raise_error(Aliyun::Opensearch::Error::AliyunService)

        allow(client).to receive(:valid_response).and_raise(Aliyun::Opensearch::Error::InvalidResponseBody, response)
        expect { client.call(:get, '/a/b/c', {}) }.to raise_error(Aliyun::Opensearch::Error::InvalidResponseBody)
      end

      it '请求失败, 转换为内部HttpBase异常' do
        connection = double(Faraday)
        allow(connection).to receive(:send).and_raise(Faraday::Error)
        client.instance_variable_set(:@connection, connection)

        expect { client.call(:get, '/a/b/c', {}) }.to raise_error(Aliyun::Opensearch::Error::HttpBase)
      end
    end
  end

  describe "valid_response" do
    let (:response) do
      rsponse = double(Faraday::Response)
      allow(rsponse).to receive(:body).and_return('{"errors":[]}')
      rsponse
    end

    it 'body参数为空, 抛出异常' do
      expect { client.valid_response(response, {}) }.to raise_error(Aliyun::Opensearch::Error::InvalidResponseBody)
    end

    it 'body参数不包含status字段, 抛出异常' do
      expect { client.valid_response(response, { 'foo' => 'bar' }) }.to raise_error(Aliyun::Opensearch::Error::InvalidResponseBody)
    end

    it 'body参数的status字段不是OK, 抛出异常' do
      expect { client.valid_response(response, { 'status' => 'FAIL' }) }.to raise_error(Aliyun::Opensearch::Error::AliyunService)
    end

    it 'body参数的status字段是OK, 不抛出异常' do
      expect { client.valid_response(response, { 'status' => 'OK' }) }.to_not raise_error
    end
  end
end
