class ApplicationQuery
  class << self
    def resolve(...)
      new.resolve(...)
    end
  end

  attr_reader :relation

  def initialize(relation)
    @relation = relation
  end

  def resolve(*args)
    relation
  end
end
