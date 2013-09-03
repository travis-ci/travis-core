class Event < Travis::Model
  belongs_to :repository
  belongs_to :source, :polymorphic => true

  serialize :data

  class << self
    def recent
      limit(50).descending
    end

    def descending
      order(arel_table[:id].desc)
    end
  end
end
