job, repository = @hash.values_at(:job, :repository)

node(:type) { job.class.name.demodulize.underscore }

child job => :build do
  attributes :id, :number
  glue(job.commit) { attributes :commit, :branch }
  node(:ref) { job.commit.ref } if job.commit.pull_request?
end

child repository => :repository do
  attributes :id
  node(:slug) { |repository| repository.slug }
  node(:source_url) { repository.source_url }
end

glue(job) { attribute :config }
