# frozen_string_literal: true

module Aliyun
  module Opensearch
    #
    # 异常模块
    #
    # @author shawn.han <shawn.han@rccchina.com>
    #
    module Error
      #
      # 请求异常基类
      #
      # @author shawn.han <shawn.han@rccchina.com>
      #
      class HttpBase < Faraday::Error
      end

      #
      # 阿里云异常基类
      #
      # @author shawn.han <shawn.han@rccchina.com>
      #
      class AliyunService < HttpBase
        ERRCODE_ALIYUN_SYS = (1000..1999).freeze # 系统级别（1000-1999）
        ERRCODE_ALIYUN_APP = (2000..2999).freeze # 应用相关（2000-2999）
        ERRCODE_ALIYUN_DOC = (3000..3999).freeze # 文档相关（3000-3999）
        ERRCODE_ALIYUN_AUTH = (4000..4999).freeze # 授权相关（4000-4999）
        ERRCODE_ALIYUN_USER = (5000..5999).freeze # 用户相关（5000-5999）
        ERRCODE_ALIYUN_SEARCH = (6000..6999).freeze # 搜索相关（6000-6999）
        ERRCODE_ALIYUN_CMD = (7000..7999).freeze # 数据处理相关（7000-7999）
        ERRCODE_ALIYUN_COMMON = (8000..8999).freeze # 文档错误内部通知（8000-8999）
        ERRCODE_ALIYUN_TEMPLETE = (9000..9999).freeze # 模板相关（9000-9999）
        ERRCODE_ALIYUN_SYNC = (10_000..).freeze # 数据同步相关（10000-）

        attr_reader :response

        #
        # 初始化
        #
        # @author shawn.han <shawn.han@rccchina.com>
        #
        # @param [Faraday::Response] response 接口返回结果
        #
        def initialize(response)
          @response = response
          @body = JSON.parse(response.body)

          super("RequestId:#{@body['request_id']} Message:#{errors_message}", response)
        end

        #
        # 获取错误信息
        #
        # @author shawn.han <shawn.han@rccchina.com>
        #
        # @return [String] 错误消息
        #
        def errors_message
          @body['errors'].map do |error|
            "[#{error['code']}] #{error['message']}"
          end.join("\n")
        end
      end

      #
      # 空参数异常
      #
      # @author shawn.han <shawn.han@rccchina.com>
      #
      class EmptyParam < ArgumentError
        #
        # 初始化
        #
        # @author shawn.han <shawn.han@rccchina.com>
        #
        def initialize
          super('Param Can Not Be Empty')
        end
      end

      #
      # 无效返回结果异常
      #
      # @author shawn.han <shawn.han@rccchina.com>
      #
      class InvalidResponseBody < HttpBase
        #
        # 初始化
        #
        # @author shawn.han <shawn.han@rccchina.com>
        #
        def initialize(response)
          super('Response Body is Invalid', response)
        end
      end
    end
  end
end
