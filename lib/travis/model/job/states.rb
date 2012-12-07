require 'active_support/concern'

class Job

  # Common states logic that is shared by all jobs. Most notable bits:
  #
  #  * Adds an after_commit hook that notifies event handler about the `create`
  #    event once the record has been committed to the db.
  #  * Overwrites update_attributes so that state event related attributes
  #    trigger the respective state event (e.g. updating `started_at` will
  #    instead trigger the `start` event).
  module States
    extend ActiveSupport::Concern

    included do
    end
  end
end
