# frozen_string_literal: true

module Aliyun
  module Opensearch
    module ClientExt
      module Traffic
        class Header
          #
          # HTTP请求header - 请求认证模块
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          module Credentials
            SIGN_PREFIX = 'OPENSEARCH'

            def authorization
              "#{SIGN_PREFIX} #{@access_key_id}:#{signature}"
            end

            def signature
              @signature ||= begin
                sign_body = [@request_method, self.content_md5, self.content_type, self.date, canonicalized_open_search_headers, canonicalized_resource].join("\n")

                Base64.encode64(
                  OpenSSL::HMAC.digest(
                    OpenSSL::Digest.new('sha1'),
                    @access_key_secret,
                    sign_body
                  )
                )
              end
            end

            #
            # 生成 CanonicalizedOpenSearchHeaders
            #
            # @author shawn.han <shawn.han@rccchina.com>
            #
            # @see https://help.aliyun.com/document_detail/54237.html#section-92h-jsb-rlu
            #
            # @return [String] CanonicalizedOpenSearchHeaders
            #
            def canonicalized_open_search_headers
              @canonicalized_open_search_headers ||= self.x_opensearch_headers.to_a.sort { |x, y| x[0] <=> y[0] }.map do |e|
                "#{e[0].downcase}:#{e[1]}"
              end.join("\n")
            end

            #
            # 生成 CanonicalizedResource
            #
            # @author shawn.han <shawn.han@rccchina.com>
            #
            # @see https://help.aliyun.com/document_detail/54237.htm
            #
            # @return [String] CanonicalizedResource
            #
            def canonicalized_resource
              path = @path
              query = nil

              if @request_method == 'GET'
                # 按照阿里云文档生成query, see: https://help.aliyun.com/document_detail/54237.htm#section-ni9-hgi-tal
                query = @api_params.to_a.sort { |x, y| x[0] <=> y[0] }.map do |e|
                  unless e[1].nil?
                    [e[0], (e[1].to_s == '' ? nil : e[1].to_s)]
                  end
                end.compact

                # encode_www_form方法文档中描述一些字符不会转移, 这里手动进行处理
                # This method doesn't convert *, -, ., 0-9, A-Z, _, a-z, but does convert SP (ASCII space) to + and converts others to %XX.
                query = URI.encode_www_form(query).gsub('+', '%20').gsub('*', '%2A')
              end

              [path, query].compact.reject(&:empty?).join('?')
            end
          end
        end
      end
    end
  end
end
