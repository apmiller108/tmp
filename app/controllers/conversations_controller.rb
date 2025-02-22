class ConversationsController < ApplicationController
  layout 'conversations', except: :index
  layout 'application', only: :index

  before_action :set_conversation, only: %i[update destroy]

  def index
    relation = current_user.conversations
    relation = relation.where(memo_id: search_params[:q][:memo_id]) if search_params.dig(:q, :memo_id)
    @conversations, @cursor = Paginate.call(relation:, limit: 15, cursor: params[:c], order: { updated_at: :desc })

    respond_to do |format|
      format.html
      format.turbo_stream
      format.json do
        render json: @conversations.as_json(only: %i[id created_at updated_at]), status: :ok
      end
    end
  end

  def new
    @conversation_form = ConversationForm.new(user: current_user)
  end

  def create
    @conversation_form = ConversationForm.new(conversation_params)
    respond_to do |format|
      if @conversation_form.save
        format.turbo_stream do
          # redirect_to edit_conversation_path(@conversation_form.conversation), status: :see_other
        end
        format.json do
          render json: @conversation_form.conversation.as_json(only: %i[id memo_id created_at updated_at]),
                 status: :created
        end
      else
        format.turbo_stream do
          flash.now.alert = t('unable_to_save', model_name: t('conversation.name'))
          flash_component = FlashMessageComponent.new(flash:, record: @conversation_form)

          render turbo_stream: [
                   turbo_stream.update(flash_component.id, flash_component),
                   turbo_stream.replace(
                     'prompt-form',
                     PromptFormComponent.new(conversation_form: @conversation_form).render_in(view_context)
                   )
                 ],
                 status: :unprocessable_entity
        end
        format.json do
          render json: { error: { message: @conversation_form.errors.full_messages.join(';') } },
                 status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @conversation = current_user.conversations
                                .includes(
                                  turns: { turnable: [:file_attachment, :file_blob, :image_attachment, :image_blob] }
                                ).find(params[:id])
    @conversation_form = ConversationForm.new(user: current_user, conversation: @conversation)
    respond_to do |format|
      format.html
    end
  end

  def update
    @conversation_form = ConversationForm.new(conversation_params.merge(conversation: @conversation))
    respond_to do |format|
      if @conversation_form.save
        format.turbo_stream do
          render 'conversations/update',
                 locals: { conversation_form: @conversation_form },
                 status: :ok
        end
        format.json do
          render json: @conversation_form.conversation.as_json(only: %i[id memo_id created_at updated_at]), status: :ok
        end
      else
        format.turbo_stream do
          flash.now.alert = t('unable_to_save', model_name: t('conversation.name'))
          flash_component = FlashMessageComponent.new(flash:, record: @conversation_form)

          render turbo_stream: [turbo_stream.update(flash_component.id, flash_component)],
                 status: :unprocessable_entity
        end
        format.json do
          render json: { error: { message: @conversation_form.errors.full_messages.join(';') } },
                 status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @conversation.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(helpers.list_dom_id(@conversation))
      end
      format.html { redirect_to conversations_path, notice: 'Conversation deleted' }
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def search_params
    params.permit(:c, :format, q: %i[memo_id])
  end

  def conversation_params
    params.require(:conversation).permit(
      :title,
      :memo_id,
      :turnable_type,
      :prompt,
      :text_id,
      :temperature,
      :generate_text_preset_id,
      :model,
      :file
    ).merge(user: current_user)
  end
end
