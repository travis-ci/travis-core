# RSpec::Matchers.define :serve_result_image do |result|
#   match do |request|
#     path = "#{Rails.root}/public/images/result/#{result}.png"
#     controller.expects(:send_file).with(path, { :type => 'image/png', :disposition => 'inline' }).once
#     request.call
#   end
# end

