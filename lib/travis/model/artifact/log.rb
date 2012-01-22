class Artifact::Log < Artifact
  class << self
    def prepend(id, chars)
      update_all(["content = ? || COALESCE(content, '')", chars], ["job_id = ?", id])
    end

    # use job_id to avoid loading a log artifact into memory
    def append(id, chars)
      update_all(["content = COALESCE(content, '') || ?", chars], ["job_id = ?", id])
    end
  end

  def prepend(chars)
    persisted? ? self.class.prepend(id, chars) : self.content = "#{chars}#{content}"
  end

  # def append_message(severity, message)
  #   self.class.append(id, "\\n\\n#{colorize(severity == :warn ? :yellow : :green, message)}")
  # end
end

