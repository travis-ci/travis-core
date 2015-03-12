if ENV['COVERAGE']
  SimpleCov.start('rails') do
    add_filter '/vendor/'
  end
end

# vim:filetype=ruby
