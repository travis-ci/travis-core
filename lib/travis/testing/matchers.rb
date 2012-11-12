# RSpec::Matchers.define :serve_result_image do |result|
#   match do |request|
#     path = "#{Rails.root}/public/images/result/#{result}.png"
#     controller.expects(:send_file).with(path, { :type => 'image/png', :disposition => 'inline' }).once
#     request.call
#   end
# end

RSpec::Matchers.define :issue_queries do |count|
  match do |code|
    queries = call(code)

    failure_message_for_should do
      (["expected #{count} queries to be issued, but got #{queries.size}:"] + queries).join("\n\n")
    end

    queries.size == count
  end

  def call(code)
    queries = []
    ActiveSupport::Notifications.subscribe 'sql.active_record' do |name, start, finish, id, payload|
      queries << payload[:sql] unless payload[:sql] =~ /ROLLBACK/
    end
    code.call
    queries
  end
end

RSpec::Matchers.define :publish_instrumentation_event do |data|
  match do |event|
    data.each do |key, value|
      event[key].should == value
    end
    [:uuid, :event, :started_at, :finished_at, :duration].each do |key|
      event.key?(key).should be_true
    end
    true
  end
end

