# Supports both cursor based and page/offset based pagination. Works with the
# PaginationComponent to produce infinite scrolls lists.
module Paginate
  class << self
    # Cursor based pagination
    def call(relation:, limit:, cursor:, order: { created_at: :desc })
      # Increment by 1 to get the next cursor. The "cursor" record is not returned
      # as part of the records set.
      relation = relation.order(order).limit(limit + 1)
      relation = relation.where(id: cursor_range(cursor, order)) if cursor

      records = relation.to_a
      # Remove "cursor" record but return its ID to set the next cursor.
      # No cursor means we're at the end.
      cursor = records.size > limit ? records.pop.id : nil

      [records, cursor]
    end

    # Page and offset pagination
    def paginate(relation:, page: 0, per_page: 15, order: { created_at: :desc })
      page = page.to_i
      per_page = [per_page.to_i, 1].max
      offset = [(page - 1), 0].max * per_page
      total_count = relation.count
      total_pages = (total_count.to_f / per_page).ceil

      # Convert to array to use size property in metadata
      records = relation.order(order).limit(per_page).offset(offset).to_a

      # Calculate pagination metadata
      metadata = {
        current_page: page,
        per_page:,
        total_count:,
        total_pages:,
        has_next_page: page < total_pages,
        has_prev_page: page > 1
      }

      [
        records,
        metadata
      ]
    end

    private

    def cursor_range(cursor, order)
      direction = order.values[0]
      if direction == :desc
        ..cursor
      else
        cursor..
      end
    end
  end
end
