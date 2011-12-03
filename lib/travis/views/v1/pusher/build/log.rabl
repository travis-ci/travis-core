job, repository = @hash.values_at(:build, :repository)

child job => :build do
  attributes :id

  node(:parent_id) { job.owner_id } if job.is_a?(Job)
end

child job => :repository do
  node(:id) { job.repository_id }
end


