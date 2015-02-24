require 'travis/model'

class Branch < Travis::Model
  belongs_to :repository
  belongs_to :last_build, class_name: 'Build'

  def self.fetch(repository, name, force_update = false)
    name        ||= 'master'
    repository_id = Integer === repository ? repository : repository.id
    branch        = where(repository_id: repository_id, name: name).first_or_initialize

    if branch.new_record? or force_update
      branch.last_build = repository.last_build_on(branch.name)
      branch.save!
    end

    branch
  end

  def self.update_build(repository, name)
    fetch(repository, name, true)
  end
end
