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

  def initialize(relation: Conversation.all, params: {})
    @params = params || {}
    @relation = relation
    @applied_filters = []
  end

  def results
    return relation if params.blank?

    apply_memo_filter
    apply_semantic_filter
    apply_related_conversations_filter

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

  def conversation_id
    params[:conversation_id]
  end

  private

  def apply_memo_filter
    return @relation unless params[:memo_id]

    @relation = relation.where(memo_id: params[:memo_id])
  end

  def apply_semantic_filter
    return @relation unless search_term

    vector = Embeddings::Voyage.create_embeddings(
      text: search_term,
      input_type: :query
    ).embeddings.first.vector

    @relation = relation.similar_to(vector, VECTOR_RELEVANCE_THRESHOLD).tap do
      applied_filters << :semantic
    end
  end

  def apply_related_conversations_filter
    return @relation unless conversation_id

    @relation = relation.similar_to(
      Conversation.where(id: conversation_id).pick(:embedding),
      VECTOR_RELEVANCE_THRESHOLD
    ).where.not(id: conversation_id).tap { applied_filters << :related_conversations }
  end
end
