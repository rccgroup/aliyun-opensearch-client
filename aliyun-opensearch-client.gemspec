# frozen_string_literal: true

require_relative 'lib/aliyun/opensearch/version'

Gem::Specification.new do |spec|
  spec.name          = 'aliyun-opensearch-client'
  spec.version       = Aliyun::Opensearch::VERSION
  spec.authors       = ['shawn.han']
  spec.email         = ['shawn.han@rccchina.com']

  spec.summary       = 'Aliyun Opensearch 服务客户端'
  spec.description   = '对接Aliyun Opensearch 的流量API HTTP接口, 生成签名并发送请求'
  spec.homepage      = 'https://github.com/rccgroup/aliyun-opensearch-client'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.1.4')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org/'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/rccgroup/aliyun-opensearch-client'
  spec.metadata['changelog_uri'] = 'https://github.com/rccgroup/aliyun-opensearch-client/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 0.10.0'

  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
end
