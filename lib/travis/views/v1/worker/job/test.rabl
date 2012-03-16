job, repository = @hash.values_at(:job, :repository)

node(:type) { job.class.name.demodulize.underscore }

child job => :build do
  attributes :id, :number
  glue(job.commit) { attributes :commit, :branch }
end

child repository => :repository do
  attributes :id
  node(:slug) { |repository| repository.slug }
  node(:git_url) { "git://github.com/#{repository.slug}.git" }
end

glue(job) { attribute :config }
