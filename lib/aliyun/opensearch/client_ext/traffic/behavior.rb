# frozen_string_literal: true

module Aliyun
  module Opensearch
    module ClientExt
      module Traffic
        #
        # 各种接口行为
        #
        # @author shawn.han <shwan.han@rccchina.com>
        #
        module Behavior
          API_SEARCH = '/v3/openapi/apps/%{app_name}/search'
          API_ACTION = '/v3/openapi/apps/%{app_name}/%{table_name}/actions/bulk'

          ACTION_CMD_KEY = 'cmd'
          ACTION_CMD_INSERT = 'add'
          ACTION_CMD_UPDATE = 'update'
          ACTION_CMD_DELETE = 'delete'

          #
          # 搜索接口
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @param [Hash] params 参数
          # @see https://help.aliyun.com/document_detail/57155.html
          #
          # @return [Hash] 查询结果
          #
          def search(params)
            raise Error::EmptyParam if params.nil? || params.empty?

            self.call(:get, complete_path(API_SEARCH), params)['result']
          end

          #
          # 插入操作
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @param [String] table_name 操作对象的表名
          # @param [Hash] params 参数
          # @see https://help.aliyun.com/document_detail/57154.html
          #
          # @return [Boolean] 处理结果
          #
          def insert(table_name, params)
            action(table_name, ACTION_CMD_INSERT, params)
          end

          #
          # 更新操作
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @param [String] table_name 操作对象的表名
          # @param [Hash] params 参数
          # @see https://help.aliyun.com/document_detail/57154.html
          #
          # @return [Boolean] 处理结果
          #
          def update(table_name, params)
            action(table_name, ACTION_CMD_UPDATE, params)
          end

          #
          # 删除操作
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @param [String] table_name 操作对象的表名
          # @param [Hash] params 参数
          # @see https://help.aliyun.com/document_detail/57154.html
          #
          # @return [Boolean] 处理结果
          #
          def delete(table_name, params)
            action(table_name, ACTION_CMD_DELETE, params)
          end

          #
          # 操作接口
          # @note 操作接口的几个注意点(此为Aliyun Opensearch服务内部的处理)
          #   1. add操作时, 如果数据已经存在, 会直接更新这条数据, 也不会报错
          #   2. update操作时, 如果数据不存在, 不会直接新建数据, 也不会报错
          #   3. delete操作时, 如果数据不存在, 不会进行操作, 也不会报错
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @param [String] table_name 操作对象的表名
          # @param [String] action 操作类型
          # @param [Array|Hash] params 参数
          #
          # @return [Boolean] 处理结果
          #
          def action(table_name, action, params)
            raise Error::EmptyParam if params.nil? || params.empty?

            self.call(:post, complete_path(API_ACTION, table_name: table_name), JSON.generate(complete_action_params(params, action)))['result']
          end

          private

          #
          # 返回完整的接口路径
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @param [String] path 接口路径
          # @param [String] table_name 表名
          #
          # @return [String] 完整的接口路径
          #
          def complete_path(path, table_name: nil)
            options = { app_name: self.app }
            options.merge!(table_name: table_name) unless table_name.nil?

            format(path, options)
          end

          #
          # 返回完整的参数
          #
          # @author shawn.han <shawn.han@rccchina.com>
          #
          # @param [Array|Hash] params 参数
          # @param [String] action 操作类型
          #
          # @return [Array<Hash>] 完整的参数
          #
          def complete_action_params(params, action)
            # 判断是否需要补充fields字段
            need_cmplete_fields_key = proc { |param| (['fields', :fields] & param.keys).empty? || (!param['fields'].is_a?(Hash) && !param[:fields].is_a?(Hash)) }

            # 添加操作类型
            if params.is_a?(Array)
              params = params.map do |e|
                e = { 'fields' => e } if need_cmplete_fields_key.call(e)
                e.merge(ACTION_CMD_KEY => action)
              end
            else
              params = { 'fields' => params } if need_cmplete_fields_key.call(params)
              params = [params.merge(ACTION_CMD_KEY => action)]
            end

            params
          end
        end
      end
    end
  end
end
