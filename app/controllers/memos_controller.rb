class MemosController < ApplicationController
  def index
    @memos = current_user.memos.order(created_at: :desc)
  end

  def show
    @memo = current_user.memos.find(params[:id])
  end

  def new
    @memo = current_user.memos.new
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    @memo = current_user.memos.create(memo_params)
    status = @memo.persisted? ? :created : :unprocessable_entity
    respond_to do |format|
      format.turbo_stream do
        render(
          inline: turbo_stream.replace('new_memo', component_for(memo: @memo).render_in(view_context)),
          status:
        )
      end
      format.html do
        if @memo.persisted?
          redirect_to user_memo_path(current_user, @memo)
        else
          render :new, status:
        end
      end
    end
    TranscribableContentHandlerJob.perform_async(@memo.id) if @memo.persisted?
  end

  def edit
    @memo = current_user.memos.find(params[:id])
  end

  def update
    @memo = current_user.memos.find(params[:id])

    if @memo.update(memo_params)
      redirect_to user_memo_path(current_user, @memo)
      TranscribableContentHandlerJob.perform_async(@memo.id)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    memo = current_user.memos.find(params[:id])
    memo.destroy
    respond_to do |format|
      format.turbo_stream do
        if request.referrer == user_memos_url(current_user)
          render turbo_stream: turbo_stream.remove(memo)
        else
          redirect_to user_memos_path(current_user), status: :see_other, notice: 'Memo was deleted'
        end
      end
      format.html { redirect_to user_memos_path }
    end
  end

  private

  def component_for(memo:)
    if memo.persisted?
      MemoComponent.new(memo: @memo)
    else
      MemoFormComponent.new(memo: @memo)
    end
  end

  def memo_params
    params.require(:memo).permit(:content)
  end
end
