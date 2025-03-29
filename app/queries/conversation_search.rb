class ConversationSearch
  attr_reader :params, :relation

  def initialize(relation:, params: {})
    @params = params
    @relation = relation
  end

  def call
    apply_memo_filter
    apply_vector_search
    relation
  end

  private

  def apply_memo_filter
    return unless (memo_id = params.dig(:q, :memo_id))

    @relation = relation.where(memo_id:)
  end

  def apply_vector_search
    return unless (search_term = params.dig(:q, :term))

    response = Embeddings::Voyage.create_embedding(
      text: search_term,
      input_type: :query
    )

    @relation = relation.nearest_neighbors(:embeddings, response.embeddings.first.vector, distance: 'cosine')
  end
end
