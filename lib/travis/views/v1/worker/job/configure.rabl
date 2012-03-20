job, repository = @hash.values_at(:job, :repository)

node(:type) { job.class.name.demodulize.underscore }

child job => :build do
  attributes :id
  glue(job.commit) { attributes :commit, :branch }
  node(:config_url) { job.commit.config_url }
end

child repository => :repository do
  attributes :id
  node(:slug) { |repository| repository.slug }
end
