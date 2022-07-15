# frozen_string_literal: true

# require header folder ruby file
%w[credentials].each do |file|
  require File.join(File.dirname(__FILE__), 'header', file)
end

module Aliyun
  module Opensearch
    module ClientExt
      module Traffic
        #
        # 流量API HTTP请求header
        #
        # @author shawn.han <shawn.han@rccchina.com>
        #
        class Header
          # 默认 conten-type
          DEFAULT_CONTENT_TYPE = 'application/json'
          # 默认 user-agent, 内容参考阿里云官方openapi sdk: https://github.com/aliyun/openapi-core-ruby-sdk/blob/master/lib/aliyunsdkcore.rb
          DEFAULT_UA = "AlibabaCloud (#{Gem::Platform.local.os}; #{Gem::Platform.local.cpu}) Ruby/#{RUBY_VERSION} Core/ALiyunOpensearchClient-#{Aliyun::Opensearch::VERSION}"

          # nonce后缀最小长度
          NONCE_SUFFIX_MIN = 100_000
          # nonce后缀最大长度
          NONCE_SUFFIX_MAX = 999_999

          include Credentials # 签名认证模块

          #
          # 创建实例
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @param [String] request_method 接口请求方法(GET POST...)
          # @param [String] path 请求资源路径
          # @param [Hash] api_params 请求接口参数
          # @param [String] access_key_id 阿里云 AccessKeyId
          # @param [String] access_key_secret 阿里云 AccessKeySecret
          #
          def initialize(request_method, path, api_params: nil, access_key_id: nil, access_key_secret: nil)
            @request_method = request_method.to_s.upcase
            @path = path

            @api_params = api_params

            @access_key_id = access_key_id || Configuration.access_key_id
            @access_key_secret = access_key_secret || Configuration.access_key_secret
          end

          #
          # 生成Header的Hash结构
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @return [Hash] 请求用到的所有Header内容
          #
          def generate
            result = {
              'User-Agent' => DEFAULT_UA,
              'Content-Type' => content_type,
              'Date' => date,
            }.merge(x_opensearch_headers)
            result.merge!('Content-Md5' => content_md5) if content_md5
            result.merge!('Authorization' => authorization)
            result
          end

          #
          # 以X-Opensearch开头的header
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @return [Hash] 以X-Opensearch开头的header
          #
          def x_opensearch_headers
            {
              'X-Opensearch-Nonce' => x_opensearch_nonce,
            }
          end

          #
          # hearder中 Content-Type的值
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @return [String] Content-Type的值
          #
          def content_type
            @content_type ||= DEFAULT_CONTENT_TYPE
          end

          #
          # 生成 header中 X-Opensearch-Nonce的值
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @see https://help.aliyun.com/document_detail/54237.html#section-92h-jsb-rlu
          #
          # @return [String] X-Opensearch-Nonce的值
          #
          def x_opensearch_nonce
            @x_opensearch_nonce ||= "#{time_now.to_i}#{rand(NONCE_SUFFIX_MIN..NONCE_SUFFIX_MAX)}"
          end

          #
          # 生成 header中 Date的值
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @return [String] Date的值
          #
          def date
            @date ||= time_now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
          end

          #
          # 生成 header中 Content-MD5的值
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @return [String] Content-MD5的值
          #
          def content_md5
            Digest::MD5.hexdigest(@api_params.to_json) if @request_method == 'POST' && @api_params
          end

          private

          #
          # 当前时间
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @return [Time] 当前时间
          #
          def time_now
            @time_now ||= Time.now
          end
        end
      end
    end
  end
end
