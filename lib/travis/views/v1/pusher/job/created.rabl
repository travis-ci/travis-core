job = @hash[:job]
object job

attributes :id, :number, :queue, :repository_id

node(:build_id) { job.source_id }

