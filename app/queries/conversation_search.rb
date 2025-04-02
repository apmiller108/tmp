class ConversationSearch
  attr_reader :params, :relation, :applied_filters

  # Threshold for vector similarity search relevance.
  # Controls the maximum distance allowed between the query vector and document vectors.
  #
  # - Lower values (closer to 0) result in more precise, tightly-clustered search results
  # - Higher values (closer to 1) allow for broader, less strictly relevant results
  #
  # The value represents the cosine distance between vectors:
  # - 0.0 means exact match
  # - 1.0 means completely dissimilar
  #
  # Adjust this threshold to balance between search precision and result breadth.
  VECTOR_RELEVANCE_THRESHOLD = 0.75

  def initialize(relation:, params: {})
    @params = params || {}
    @relation = relation
    @applied_filters = []
  end

  def results
    return relation if params.blank?

    apply_memo_filter
    apply_semantic_filter
    relation
  end

  def order
    case params[:order]
    when 'neighbor_distance asc'
      { neighbor_distance: :asc }
    else
      { updated_at: :desc }
    end
  end

  def search_term
    params[:term]
  end

  private

  def apply_memo_filter
    return unless params[:memo_id]

    @relation = relation.where(memo_id: params[:memo_id])
  end

  def apply_semantic_filter
    return unless search_term

    vector = Embeddings::Voyage.create_embeddings(
      text: search_term,
      input_type: :query
    ).embeddings.first.vector

    @relation = relation.select("conversations.*, (embedding <=> '#{vector}') AS neighbor_distance")
                        .where('embedding <=> ? < ?', vector.to_s, VECTOR_RELEVANCE_THRESHOLD)

    applied_filters << :semantic
  end
end
