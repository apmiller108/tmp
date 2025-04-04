# Supports both cursor based and page/offset based pagination. Works with the
# PaginationComponent to produce infinite scrolls lists.
module Paginate
  class << self
    # Implements cursor-based pagination for ActiveRecord relations.
    #
    # @param relation [ActiveRecord::Relation] The base relation to paginate
    # @param limit [Integer] Maximum number of records to return
    # @param cursor [Integer, nil] ID of the last record from the previous page, or nil for the first page
    # @param order [Hash] Sorting order, defaults to created_at: :desc
    #
    # @return [Array<Array, Integer, nil>] Array containing records and the next cursor value (nil if no more records)
    # @note The cursor record itself is not included in the returned records
    def cursor(relation:, limit:, cursor:, order: { created_at: :desc })
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

    # Implements traditional page/offset-based pagination for ActiveRecord relations.
    #
    # @param relation [ActiveRecord::Relation] The base relation to paginate
    # @param page [Integer] Page number to retrieve (starts at 1)
    # @param per_page [Integer] Number of records per page, minimum 1, defaults
    # to 15. 0 if we just need the metadata for initialization (useful for the
    # PaginationComponent)
    # @param order [Hash] Sorting order, defaults to created_at: :desc
    #
    # @return [Array<Array, Hash>] Array containing records and pagination metadata
    # @option return[1] :current_page [Integer] Current page number
    # @option return[1] :per_page [Integer] Records per page
    # @option return[1] :total_count [Integer] Total number of records
    # @option return[1] :total_pages [Integer] Total number of pages
    # @option return[1] :has_next_page [Boolean] Whether there is a next page
    # @option return[1] :has_prev_page [Boolean] Whether there is a previous page
    def paginate(relation:, page: 0, per_page: 15, order: { created_at: :desc })
      page = page.to_i
      per_page = [per_page.to_i, 1].max
      offset = [(page - 1), 0].max * per_page
      # Reslect ID to reset any select query customizations (eg,
      # neighbor_distance) which makes generates invalid SQL when combined with
      # `count`
      total_count = relation.dup.reselect(:id).count
      total_pages = (total_count.to_f / per_page).ceil

      records = relation.order(order).limit(per_page).offset(offset)

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
