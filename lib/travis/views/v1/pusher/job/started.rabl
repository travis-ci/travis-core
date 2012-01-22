job = @hash[:job]
object job

attributes :id, :started_at, :worker, :sponsor

node(:build_id) { job.owner_id }
