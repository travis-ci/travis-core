class Artifact::Log < Artifact
  class << self
    # use job_id to avoid loading a log artifact into memory
    def append(id, chars)
      update_all(["content = COALESCE(content, '') || ?", filter(chars)], ["job_id = ?", id])
    end

    private

      def filter(chars)
        # postgres seems to have issues with null chars
        chars.gsub("\0", '')
      end
  end

  # def append_message(severity, message)
  #   self.class.append(id, "\\n\\n#{colorize(severity == :warn ? :yellow : :green, message)}")
  # end
end

