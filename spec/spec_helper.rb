require 'bundler/setup'

require 'rspec'

require 'simplecov'
SimpleCov.start

require 'simplecov-rcov'
require 'simplecov-rcov-text'

SimpleCov.formatters = [
  SimpleCov::Formatter::RcovFormatter,
  SimpleCov::Formatter::RcovTextFormatter,
  SimpleCov::Formatter::HTMLFormatter
]

require 'tlv'