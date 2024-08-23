class ApplicationQuery
  def self.call(...)
    new.resolve(...)
  end

  attr_reader :relation

  def initialize(relation)
    @relation = relation
  end

  def resolve(*)
    relation
  end
end
