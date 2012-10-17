require 'active_record'

class Broadcast < ActiveRecord::Base
  belongs_to :recipient, :polymorphic => true

  class << self
    def for(user)
      sql = %(
        created_at >= ? AND (expired IS NULL OR expired <> ?) AND (
          recipient_type IS NULL OR
          recipient_type = ? AND recipient_id IN(?) OR
          recipient_type = ? AND recipient_id = ? OR
          recipient_type = ? AND recipient_id IN (?)
        )
      )
      where(sql, 14.days.ago, true, 'Organization', user.organization_ids, 'User', user.id, 'Repository', user.repository_ids)
    end
  end
end
