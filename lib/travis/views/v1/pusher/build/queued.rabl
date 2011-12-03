child @hash[:build] => :build do
  attributes :id, :number, :queue
end

child @hash[:repository] => :repository do
  attributes :id
  node(:slug) { |repository| repository.slug }
end

