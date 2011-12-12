build, repository = @hash.values_at(:build, :repository)

child build => :build do # TODO flatten this into the main namespace
  attributes :id, :repository_id, :number, :started_at, :config

  node(:result) { build.status }

  glue build.commit do
    attributes :commit, :branch, :message, :committed_at, :committer_name, :committer_email, :author_name, :author_email, :compare_url
  end

  code :matrix do
    build.matrix.map { |job| Travis::Renderer.hash(job, :type => :pusher, :template => 'build/started/test', :base_dir => base_dir) } if build.respond_to?(:matrix)
  end
end

child repository => :repository do
  attributes :id, :description, :last_build_id, :last_build_number, :last_build_started_at, :last_build_finished_at, :last_build_language

  node(:last_build_result) { repository.last_build_status }
  node(:slug) { repository.slug }
end

