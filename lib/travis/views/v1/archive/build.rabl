object @build
repository = @build.repository

attributes :id, :number, :started_at, :finished_at, :config

node(:result) { @build.status }

glue @build.commit do
  attributes :commit, :branch, :message, :committed_at, :committer_name, :committer_email, :author_name, :author_email
end

code :matrix do
  @build.matrix.map { |job| Travis::Renderer.hash(job, :type => :archive, :template => 'build/test', :base_dir => base_dir) }
end

child repository => :repository do
  attributes :id
  node(:slug) { repository.slug }
end


