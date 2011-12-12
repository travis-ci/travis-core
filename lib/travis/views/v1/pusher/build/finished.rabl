build, repository = @hash.values_at(:build, :repository)

child build => :build do
  attributes :id, :finished_at

  node(:result) { build.status }
end

child repository => :repository do
  attributes :id, :last_build_id, :last_build_number, :last_build_started_at, :last_build_finished_at, :last_build_duration

  node(:last_build_result) { |repository| repository.last_build_status }
  node(:slug) { |repository| repository.slug }
end
