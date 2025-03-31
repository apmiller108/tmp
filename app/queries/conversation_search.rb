class ConversationSearch
  attr_reader :params, :relation

  VECTOR_RELEVANCE_THRESHOLD = 0.75

  def initialize(relation:, params: {})
    @params = params || {}
    @relation = relation
  end

  def results
    return relation if params.blank?

    apply_memo_filter
    apply_vector_search
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

  private

  def apply_memo_filter
    return unless params[:memo_id]

    @relation = relation.where(memo_id: param[:memo_id])
  end

  def apply_vector_search
    return unless params[:term]

    vector = Embeddings::Voyage.create_embeddings(
      text: params[:term],
      input_type: :query
    ).embeddings.first.vector

    @relation = relation.select("conversations.*, (embedding <=> '#{vector}') AS neighbor_distance")
                        .where('embedding <=> ? < ?', vector.to_s, VECTOR_RELEVANCE_THRESHOLD)
  end
end
