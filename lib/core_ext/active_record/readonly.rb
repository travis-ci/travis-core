require 'active_record'

class ActiveRecord::Base
  def readonly
    readonly  = @readonly
    @readonly = true
    yield
    @readonly = readonly
  end
end
