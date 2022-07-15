# Aliyun::Opensearch::Client 🧯

本项目是阿里云Opensearch服务的ruby sdk, 定位类似[rsolr](https://github.com/rsolr/rsolr)之于solr  
会根据[官方文档](https://help.aliyun.com/document_detail/54237.html)生成流量API的签名, 并发送请求  
该gem最低支持的ruby版本为2.1.4

## Install

安装gem

```ruby
gem install 'aliyun-opensearch-client'
```

## Usage

```ruby
# 1. 添加配置
Aliyun::Opensearch::Configuration.endpoint = 'opensearch-cn-hangzhou.aliyuncs.com'
Aliyun::Opensearch::Configuration.access_key_id = 'A*****************z'
Aliyun::Opensearch::Configuration.access_key_secret = 'z*********************A'

# 2. 创建客户端实例
client = Aliyun::Opensearch::Client.new('your_app_name')

# 3. 发送请求
# 插入
puts client.insert('your_table', [ { id: 1, title: 'Cien años de soledad' }, { id: 2, title: 'Les Misérables' } ]) # true
puts client.insert('your_table', { id: 3, title: 'The Metamorphosis' }) # true

# 更新
puts client.update('your_table', [ { id: 1, title: 'Book - 百年孤独' }, { id: 2, title: 'Book - 悲惨世界' } ]) # true
puts client.update('your_table', { id: 3, title: 'Book - 变形记' }) # true

# 搜索
puts client.search({query: "query=default:'Book'"})
# {"searchtime"=>0.102566, "total"=>3, "num"=>3, "viewtotal"=>3, "compute_cost"=>[{"index_name"=>"your_app_name", "value"=>0.355}], "items"=>[{"id"=>"2", "index_name"=>"your_app_name"}, {"id"=>"1", "index_name"=>"your_app_name"}, {"id"=>"3", "index_name"=>"your_app_name"}], "facet"=>[]}

# 删除
puts client.delete('your_table', { id: 1 }) # true
puts client.delete('your_table', [{ id: 2 }, { id: 3 }]) # true

# 自定义接口请求
response = client.call(:get, '/v3/openapi/apps/your_app_name/suggest/your_suggest_name/search', { query: '...' })
```

## Feature
- 流量API签名认证
- 封装流量API的 数据处理 / 搜索处理 接口
- 兼容请求未封装的流量API接口

## RoadMap
- request日志追踪
- 支持流量API的 推送采集数据 / 下拉提示 / 热搜和底纹 接口
- 支持管控API (可以临时用Aliyun官方的OpenAPI解决问题)
- 支持STS认证

## 开源协议

[MIT License](https://opensource.org/licenses/MIT).
