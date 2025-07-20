class ConversationContextsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation_context, only: [:destroy]

  def index
    @search_params = search_params
    relation = current_user.conversation_contexts.includes(:conversations)

    if @search_params.dig(:q, :search).present?
      relation = relation.where(
        'filename ILIKE ? OR mime_type ILIKE ?',
        "%#{search_params[:q][:search]}%", "%#{search_params[:q][:search]}%"
      )
    end

    @conversation_contexts, @pagination = Paginate.paginate(relation:,
                                                            page: params.fetch(:page, 1),
                                                            per_page: 10,
                                                            order: { created_at: :desc })

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def destroy
    @conversation_context.destroy
    respond_to do |format|
      if @conversation_context.destroyed?
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(@conversation_context)
        end
      else
        format.turbo_stream do
          flash.now.alert = t('unable_to_delete', model_name: 'Context')
          flash_component = FlashMessageComponent.new(flash:, record: @conversation_context)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def search_params
    params.permit(:format, :page, :per_page, q: %i[search])
  end

  def set_conversation_context
    @conversation_context = current_user.conversation_contexts.find(params[:id])
  end
end
