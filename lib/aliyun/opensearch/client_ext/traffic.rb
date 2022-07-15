# frozen_string_literal: true

# require traffic folder ruby file
%w[header behavior].each do |file|
  require File.join(File.dirname(__FILE__), 'traffic', file)
end
