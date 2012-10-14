class Event < ActiveRecord::Base
  belongs_to :repository
  belongs_to :source, :polymorphic => true

  serialize :data
end
