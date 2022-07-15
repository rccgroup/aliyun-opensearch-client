# frozen_string_literal: true

module Aliyun
  module Opensearch
    #
    # 服务配置
    #
    # @author shawn.han <shawn.han@rccchina.com>
    #
    class Configuration
      class << self
        attr_accessor :endpoint # Opensearch服务地址
        attr_accessor :access_key_id # 阿里云申请的ak
        attr_accessor :access_key_secret # 阿里云申请的ak secret

        #
        # 根据设置的endpoint获取服务的url, 如果没有协议头默认设置为https
        #
        # @author shawn.han <shawn.han@rccchina.com>
        #
        # @return [String] 服务url
        #
        def opensearch_url
          endpoint =~ /^https?:\/\// ? endpoint : "https://#{endpoint}"
        end
      end
    end
  end
end
