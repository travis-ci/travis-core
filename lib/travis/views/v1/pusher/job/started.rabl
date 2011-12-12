job = @hash[:job]
object job

attributes :id, :started_at

node(:build_id) { job.owner_id }
