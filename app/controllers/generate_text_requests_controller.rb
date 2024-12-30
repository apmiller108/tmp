class GenerateTextRequestsController < ApplicationController
  def create
    generatate_text_request = current_user.generate_text_requests.create(generate_text_request_params)

    respond_to do |format|
      format.turbo_stream do
        if generatate_text_request.persisted?
          GenerateTextJob.perform_async(generatate_text_request.id)
          render(
            turbo_stream: [
              turbo_stream.append(
                'conversation-turns',
                ConversationTurnComponent.new(prompt_to_turn).render_in(view_context)
              ),
              turbo_stream.append(
                'conversation-turns',
                ConversationTurnComponent.new(Conversation::Turn.for_response(''), pending: true).render_in(view_context)
              )
            ],
            status: :created
          )
        else
          flash.now.alert = t('unable_to_generate_text')
          flash_component = FlashMessageComponent.new(flash:, record: generatate_text_request)

          render turbo_stream: [
                   turbo_stream.update(flash_component.id, flash_component),
                   turbo_stream.replace(
                     'prompt-form',
                     PromptFormComponent.new(conversation:).render_in(view_context)
                   )
                 ],
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def prompt_to_turn
    Conversation::Turn.for_prompt(generate_text_request_params[:prompt])
  end

  def conversation
    @conversation ||= Conversation.find_or_initialize_by(id: conversation_id)
  end

  def conversation_id
    generate_text_request_params[:conversation_id]
  end

  def generate_text_request_params
    params.require(:generate_text_request).permit(
      :prompt, :text_id, :temperature, :generate_text_preset_id, :conversation_id
    ).merge(model: current_user.setting.text_model)
  end
end
