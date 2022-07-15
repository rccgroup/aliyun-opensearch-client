require 'spec_helper'

RSpec.describe Aliyun::Opensearch::Error::AliyunService do
  describe 'initialize' do
    it '根据参数拼接返回message' do
      response = double(Faraday::Response)
      allow(response).to receive(:body).and_return({
        request_id: 1234567890,
        errors: []
      }.to_json)

      error = described_class.new(response)

      expect(error.message).to eq 'RequestId:1234567890 Message:'
    end

    describe 'errors_message' do
      it '拼接接口返回的错误信息并且返回字符串' do
        response = double(Faraday::Response)
        allow(response).to receive(:body).and_return({
          request_id: 1234567890,
          errors: [
            {'code'=>'1001', 'message' => 'System Not Work'},
            {'code'=>'4001', 'message' => 'Access Not Allow'},
          ]
        }.to_json)

        error = described_class.new(response)

        expect(error.errors_message).to eq "[1001] System Not Work\n[4001] Access Not Allow"
      end
    end
  end
end

RSpec.describe Aliyun::Opensearch::Error::EmptyParam do
  describe 'initialize' do
    it '实例化时生成message' do
      error = described_class.new

      expect(error.message).to eq 'Param Can Not Be Empty'
    end
  end
end

RSpec.describe Aliyun::Opensearch::Error::InvalidResponseBody do
  describe 'initialize' do
    it '实例化时生成message' do
      error = described_class.new(double(Faraday::Response))

      expect(error.message).to eq 'Response Body is Invalid'
    end
  end
end
