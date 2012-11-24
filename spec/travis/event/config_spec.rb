require 'spec_helper'

describe Travis::Event::Config do
  include Travis::Testing::Stubs

  describe :send_on_finished_for? do
    combinations = [
      [nil,     :passed, { on_success: 'always' }, true ],
      [:passed, :passed, { on_success: 'always' }, true ],
      [:failed, :passed, { on_success: 'always' }, true ],

      [nil,     :failed, { on_success: 'always' }, true ],
      [:passed, :failed, { on_success: 'always' }, true ],
      [:failed, :failed, { on_success: 'always' }, true ],

      [nil,     :passed, { on_failure: 'always' }, true ],
      [:passed, :passed, { on_failure: 'always' }, true ],
      [:failed, :passed, { on_failure: 'always' }, true ],

      [nil,     :failed, { on_failure: 'always' }, true ],
      [:passed, :failed, { on_failure: 'always' }, true ],
      [:failed, :failed, { on_failure: 'always' }, true ],


      [nil,     :passed, { on_success: 'change' }, true ],
      [:passed, :passed, { on_success: 'change' }, false],
      [:failed, :passed, { on_success: 'change' }, true ],

      [nil,     :failed, { on_success: 'change' }, true ],
      [:passed, :failed, { on_success: 'change' }, true ],
      [:failed, :failed, { on_success: 'change' }, true ],

      [nil,     :passed, { on_failure: 'change' }, true ],
      [:passed, :passed, { on_failure: 'change' }, true ],
      [:failed, :passed, { on_failure: 'change' }, true ],

      [nil,     :failed, { on_failure: 'change' }, false],
      [:passed, :failed, { on_failure: 'change' }, true ],
      [:failed, :failed, { on_failure: 'change' }, false],


      [nil,     :passed, { on_success: 'never' }, false ],
      [:passed, :passed, { on_success: 'never' }, false ],
      [:failed, :passed, { on_success: 'never' }, false ],

      [nil,     :failed, { on_success: 'never' }, true  ],
      [:passed, :failed, { on_success: 'never' }, true  ],
      [:failed, :failed, { on_success: 'never' }, true  ],

      [nil,     :passed, { on_failure: 'never' }, true  ],
      [:passed, :passed, { on_failure: 'never' }, true  ],
      [:failed, :passed, { on_failure: 'never' }, true  ],

      [nil,     :failed, { on_failure: 'never' }, false ],
      [:passed, :failed, { on_failure: 'never' }, false ],
      [:failed, :failed, { on_failure: 'never' }, false ],
    ]

    combinations.each do |previous, current, config, result|
      it "returns #{result} for :webhooks if the previous build #{previous ? previous : 'is missing'}, the current build #{current} and config is #{config}" do
        build.stubs(
          config: build.config.deep_merge(notifications: config),
          state: current,
          previous_state: previous
        )
        payload = Travis::Api.data(build, for: 'event', version: 'v0')
        config  = Travis::Event::Config.new(payload)
        config.send_on_finished_for?(:webhooks).should == result
      end
    end
  end
end
