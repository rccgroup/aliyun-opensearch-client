# frozen_string_literal: true

# require client_ext folder ruby file
%w[traffic].each do |file|
  require File.join(File.dirname(__FILE__), 'client_ext', file)
end

module Aliyun
  module Opensearch
    #
    # Opensearch客户端
    #
    # @author shawn.han <shawn.han@rccchina.com>
    #
    class Client
      include ClientExt::Traffic::Behavior

      # 允许请求的action
      REQUEST_METHODS = [:get, :post].freeze

      # 应用名称
      attr_reader :app

      #
      # 客户端初始化
      #
      # @author shawn.han <shawn.han@rccchina.com>
      #
      # @param [String] app 应用名称, 即要访问的Opensearch应用的名称, 在实例管理里可以看到
      #
      def initialize(app)
        @app = app
        @connection = Faraday.new(url: Configuration.opensearch_url) do |faraday|
          faraday.response :raise_error
        end
      end

      #
      # 发送请求
      #
      # @author shawn.han <shawn.han@rccchina.com>
      #
      # @param [String|Symbol] method 接口请求方法
      # @param [String] path 接口地址
      # @param [Hash] params 接口参数
      #
      # @return [Hash] 请求结果
      #
      def call(method, path, params)
        raise ArgumentError, "Not Allow Request Method #{method}; Only Allowed #{REQUEST_METHODS}" unless REQUEST_METHODS.map { |e| [e, e.to_s, e.to_s.upcase] }.flatten.include?(method)

        response = @connection.send(method.downcase, path, params) do |request|
          api_params = (request.http_method == :get ? request.params : request.body)
          request.headers = ClientExt::Traffic::Header.new(request.http_method, request.path, api_params: api_params).generate
        end
        body = response.body.empty? ? {} : JSON.parse(response.body)

        valid_response(response, body)
        body
      rescue Error::AliyunService, Error::InvalidResponseBody => e
        raise e
      rescue Faraday::Error => e
        raise Error::HttpBase, e
      end

      #
      # 返回结果校验
      #
      # @author shawn.han <shawn.han@rccchina.com>
      #
      def valid_response(response, body)
        raise Error::InvalidResponseBody, response if body.empty? || !body.keys.include?('status')
        raise Error::AliyunService, response if body['status'] != 'OK'
      end
    end
  end
end
