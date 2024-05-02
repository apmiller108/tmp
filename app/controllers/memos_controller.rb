class MemosController < ApplicationController
  def index
    relation = current_user.memos.with_rich_text_content_and_embeds
    @memos, @cursor = Paginate.call(relation:, limit: 21, cursor: params[:c], order: { created_at: :desc })
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @memo = current_user.memos.find(params[:id])
  end

  def new
    @memo = current_user.memos.new(title: 'New memo')
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    @memo = current_user.memos.create(memo_params)
    respond_to do |format|
      if @memo.persisted?
        format.turbo_stream do
          render(
            turbo_stream: [
              turbo_stream.replace('new_memo', memo_component.render_in(view_context)),
              turbo_stream.prepend('memos', memo_card_component.render_in(view_context))
            ], status: :created
          )
        end
        format.html { redirect_to user_memo_path(current_user, @memo) }
        TranscribableContentHandlerJob.perform_async(@memo.id)
      else
        flash.now.alert = t('unable_to_save', model_name: :memo)
        flash_component = FlashMessageComponent.new(flash:, record: @memo)

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('new_memo', memo_form_component.render_in(view_context)),
            turbo_stream.update(flash_component.id, flash_component)
          ], status: :unprocessable_entity
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @memo = current_user.memos.find(params[:id])
  end

  def update
    @memo = current_user.memos.find(params[:id])

    respond_to do |format|
      if @memo.update(memo_params)
        flash.now[:success] = t('successfully_saved', model_name: 'Memo')
        flash_component = FlashMessageComponent.new(flash:, auto_dismiss: 2)

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(memo_component.id, memo_form_component.render_in(view_context)),
            turbo_stream.replace(memo_card_component.id, memo_card_component.render_in(view_context)),
            turbo_stream.update(flash_component.id, flash_component)
          ], status: :ok
        end

        format.html do
          redirect_to user_memo_path(current_user, @memo)
        end
        TranscribableContentHandlerJob.perform_async(@memo.id)
      else
        flash.now.alert = t('unable_to_save', model_name: :memo)
        flash_component = FlashMessageComponent.new(flash:, record: @memo)

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(memo_card_component.id, memo_card_component.render_in(view_context)),
            turbo_stream.update(flash_component.id, flash_component)
          ]
        end
        format.html do
          render :edit, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @memo = current_user.memos.find(params[:id])
    @memo.destroy
    respond_to do |format|
      format.turbo_stream do
        if request.referer == user_memos_url(current_user)
          render turbo_stream: [turbo_stream.remove(@memo), turbo_stream.remove(memo_card_component.id)]
        else
          redirect_to user_memos_path(current_user), status: :see_other, notice: 'Memo was deleted'
        end
      end
      format.html { redirect_to user_memos_path }
    end
  end

  private

  def component_for(memo:)
    if memo.valid?
      MemoComponent.new(memo: @memo)
    else
      MemoFormComponent.new(memo: @memo)
    end
  end

  def memo_component
    @memo_component ||= MemoComponent.new(memo: @memo)
  end

  def memo_form_component
    @memo_form_component ||= MemoFormComponent.new(memo: @memo)
  end

  def memo_card_component
    @memo_card_component ||= MemoCardComponent.new(memo: @memo)
  end

  def memo_params
    params.require(:memo).permit(:content, :title, :color)
  end
end
