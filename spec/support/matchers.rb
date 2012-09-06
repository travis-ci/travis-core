RSpec::Matchers.define :be_queued_to do |publisher|
  match do |jobs|
    expected = jobs.map(&:id)
    actual = publisher.messages.map { |message| message.first['job']['id'] }
    actual.should == expected
    # jobs.map(&:state).uniq.should == ['queued']
  end

  failure_message_for_should do |jobs|
    actual = publisher.messages.map { |message| message.first['job']['id'] }
    "expected jobs #{jobs.map(&:id)} to be enqueued. instead we have:\n" +
    "  jobs #{actual} in publish messages\n"
  end
end

RSpec::Matchers.define :contain_recipients do |expected|
  match do |actual|
    actual = Array(actual).join(',').split(',')
    expected = Array(expected).join(',').split(',')
    (actual & expected).size.should == expected.size
  end

  failure_message_for_should do |actual|
    "expected #{actual} to contain #{expected}"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual} to not contain #{expected}"
  end
end

# TODO this looks like a very weird matcher
RSpec::Matchers.define :send_email_notification_on do |event|
  match do |build|
    dispatch =  lambda { Travis::Event.dispatch(event, build) }
    dispatch.call
    dispatch.should change(ActionMailer::Base.deliveries, :size).by(1)
    ActionMailer::Base.deliveries.last
  end
end

RSpec::Matchers.define :deliver_to do |expected|
  match do |email|
    actual = (email.to || []).map(&:to_s)

    description { "be delivered to #{expected.inspect}" }
    failure_message_for_should { "expected #{email.inspect} to deliver to #{expected.inspect}, but it delivered to #{actual.inspect}" }
    failure_message_for_should_not { "expected #{email.inspect} not to deliver to #{expected.inspect}, but it did" }

    actual.sort == Array(expected).sort
  end
end

RSpec::Matchers.define :include_lines do |lines|
  match do |text|
    lines   = lines.split("\n").map { |line| line.strip }
    missing = lines.reject { |line| text.include?(line) }

    failure_message_for_should do
      "expected\n\n#{text}\n\nto include the lines\n\n#{lines.join("\n")}\n\nbut could not find the lines\n\n#{missing.join("\n")}"
    end

    missing.empty?
  end
end

RSpec::Matchers.define :have_message do |event, object|
  match do |pusher|
    description { "have a message #{event.inspect}" }
    failure_message_for_should { "expected pusher to receive #{event.inspect} but it did not. Instead it has the following messages: #{pusher.messages.map(&:inspect).join(', ')}" }
    failure_message_for_should_not { "expected pusher not to receive #{event.inspect} but it did" }

    # TODO need to test for the object/json, too!
    message = pusher.messages.detect { |message| message.first == event }
    pusher.messages.delete(message)
    !!message
  end

  def find_message
  end
end

RSpec::Matchers.define :be_queued do |*args|
  match do |job|
    @options = args.last.is_a?(Hash) ? args.pop : {}
    @queue = args.first || @options[:queue] || 'builds'
    @expected = job.is_a?(Job) ? Travis::Event::Worker.payload_for(job, :queue => 'builds') : job
    @actual = job ? self.job['args'].last.deep_symbolize_keys : nil

    @actual == @expected
  end

  def job
  end

  def jobs
  end

  failure_message_for_should do
    @actual ?
      "expected the job queued in #{@queue.inspect} to have the payload #{@actual.inspect} but had #{@expected.inspect}" :
      "expected a job with the payload #{@expected.inspect} to be queued in #{@queue.inspect} but none was found. Instead there are the following jobs:\n\n#{jobs}"
  end

  failure_message_for_should_not do
    @actual ?
      "expected the job queued in #{@queue.inspect} not to have #{@actual.inspect} but it has" :
      "expected no job with the payload #{@expected.inspect} to be queued in #{@queue.inspect} but it is"
  end
end
