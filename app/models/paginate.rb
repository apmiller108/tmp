module Paginate
  def self.call(relation:, limit:, cursor:, order: { created_at: :desc })
    # Increment by 1 to get the next cursor. The "cursor" record is not returned
    # as part of the records set.
    relation = relation.order(order).limit(limit + 1)
    relation = relation.where(id: range(cursor, order)) if cursor

    records = relation.to_a
    # Remove "cursor" record but return its ID to set the next cursor.
    # No cursor means we're at the end.
    cursor = records.size > limit ? records.pop.id : nil

    [records, cursor]
  end

  def self.range(cursor, order)
    direction = order.values[0]
    if direction == :desc
      ..cursor
    else
      cursor..
    end
  end
end
