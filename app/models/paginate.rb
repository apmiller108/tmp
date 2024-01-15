module Paginate
  def self.call(relation:, limit:, cursor:)
    relation = relation.where(id: ..cursor) if cursor
    collection = relation.limit(limit + 1).to_a
    cursor = collection.size > limit ? collection.pop.id : nil
    [collection, cursor]
  end
end
