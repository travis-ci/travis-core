job = @hash[:job]
object job

attributes :id, :finished_at

node(:result) { job.status }


