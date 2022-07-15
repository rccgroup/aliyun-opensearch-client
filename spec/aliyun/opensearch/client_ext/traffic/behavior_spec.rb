require 'spec_helper'

RSpec.describe Aliyun::Opensearch::Client do
  let(:client) { described_class.new('test_app') }

  describe "search" do
    it '请求参数为空, 抛出异常' do
      expect { client.search(nil) }.to raise_error Aliyun::Opensearch::Error::EmptyParam
      expect { client.search({}) }.to raise_error Aliyun::Opensearch::Error::EmptyParam
      expect { client.search([]) }.to raise_error Aliyun::Opensearch::Error::EmptyParam
    end

    it '搜索成功, 返回接口返回的搜索结果' do
      query_param = {query: "query=defaule:'test'"}
      query_result = [{'id': 1}, {'id': 2}, {'id': 3}]
      allow(client).to receive(:call).with(:get, '/v3/openapi/apps/test_app/search', query_param).and_return({'result' => query_result})

      expect(client.search(query_param)).to be(query_result)
    end
  end

  describe "insert" do
    it '插入成功, 返回接口返回的处理结果' do
      allow(client).to receive(:call).with(:post, '/v3/openapi/apps/test_app/test_table/actions/bulk', [{'fields' => {'a'=>1}, 'cmd' => 'add'}].to_json).and_return({'result' => true})

      expect(client.insert('test_table', {'a'=>1})).to be_truthy
    end
  end

  describe "update" do
    it '更新成功, 返回接口返回的处理结果' do
      allow(client).to receive(:call).with(:post, '/v3/openapi/apps/test_app/test_table/actions/bulk', [{'fields' => {'a'=>1}, 'cmd' => 'update'}].to_json).and_return({'result' => true})

      expect(client.update('test_table', {'a'=>1})).to be_truthy
    end
  end

  describe "delete" do
    it '删除成功, 返回接口返回的处理结果' do
      allow(client).to receive(:call).with(:post, '/v3/openapi/apps/test_app/test_table/actions/bulk', [{'fields' => {'a'=>1}, 'cmd' => 'delete'}].to_json).and_return({'result' => true})

      expect(client.delete('test_table', {'a'=>1})).to be_truthy
    end
  end

  describe "action" do
    it '请求参数为空, 抛出异常' do
      expect { client.action('test_table', 'insert', nil) }.to raise_error Aliyun::Opensearch::Error::EmptyParam
      expect { client.action('test_table', 'insert', {}) }.to raise_error Aliyun::Opensearch::Error::EmptyParam
      expect { client.action('test_table', 'insert', []) }.to raise_error Aliyun::Opensearch::Error::EmptyParam
    end

    it '请求成功, 返回接口返回的处理结果' do
      allow(client).to receive(:call).with(:post, '/v3/openapi/apps/test_app/test_table/actions/bulk', [{'fields' => {'a'=>1}, 'cmd' => 'add'}].to_json).and_return({'result' => true})

      expect(client.action('test_table', 'add', {'a'=>1})).to be_truthy
    end
  end

  describe "complete_path" do
    it "补全app_name和table_name, 返回完整的接口路径" do
      expect(client.send(:complete_path, "/%{app_name}/a/%{table_name}/c", table_name: "test_table")).to eq "/test_app/a/test_table/c"
    end

    it "路径中没有对应的key时不会报错" do
      expect(client.send(:complete_path, "/a/b/c", table_name: "test_table")).to eq "/a/b/c"
      expect(client.send(:complete_path, "/%{app_name}/b/c", table_name: "test_table")).to eq "/test_app/b/c"
    end
  end

  describe "complete_action_params" do
    it 'Array类型的参数, 不带fields字段时, 补全fields' do
      params = [ {'a'=>1}, {'a'=>2}, {'a'=>3} ]

      expect(client.send(:complete_action_params, params, 'insert')).to eq [
        {'cmd' => 'insert', 'fields' => {'a'=>1}},
        {'cmd' => 'insert', 'fields' => {'a'=>2}},
        {'cmd' => 'insert', 'fields' => {'a'=>3}},
      ]
    end

    it 'Hash类型的参数, 不带fields字段时, 补全fields' do
      params = {'a'=>1}

      expect(client.send(:complete_action_params, params, 'insert')).to eq [
        {'cmd' => 'insert', 'fields' => {'a'=>1}},
      ]
    end

    it 'Array类型的参数, 带fields字段时, 不补全fields' do
      params = [ {'fields' => {'a'=>1}}, {'fields' => {'a'=>2}}, {'fields' => {'a'=>3}} ]

      expect(client.send(:complete_action_params, params, 'insert')).to eq [
        {'cmd' => 'insert', 'fields' => {'a'=>1}},
        {'cmd' => 'insert', 'fields' => {'a'=>2}},
        {'cmd' => 'insert', 'fields' => {'a'=>3}},
      ]

      params = [ {fields: {'a'=>1}}, {fields: {'a'=>2}}, {fields: {'a'=>3}} ]

      expect(client.send(:complete_action_params, params, 'insert')).to eq [
        {'cmd' => 'insert', fields: {'a'=>1}},
        {'cmd' => 'insert', fields: {'a'=>2}},
        {'cmd' => 'insert', fields: {'a'=>3}},
      ]
    end

    it 'Hash类型的参数, 带fields字段时, 不补全fields' do
      params = {'fields' => {'a'=>1}}

      expect(client.send(:complete_action_params, params, 'insert')).to eq [
        {'cmd' => 'insert', 'fields' => {'a'=>1}},
      ]

      params = {fields: {'a'=>1}}

      expect(client.send(:complete_action_params, params, 'insert')).to eq [
        {'cmd' => 'insert', fields: {'a'=>1}},
      ]
    end
  end
end

