job = @hash[:job]
object job

attributes :id, :finished_at

node(:result)   { job.status }
node(:build_id) { job.owner_id }

