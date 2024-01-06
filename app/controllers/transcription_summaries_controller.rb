class TranscriptionSummariesController < ApplicationController
  def create
    transcription = current_user.transcriptions.find(transcription_summary_params[:transcription_id])
    summary = transcription.create_summary

    respond_to do |format|
      format.turbo_stream do
        if summary.persisted?
          enqueue_transcription_summary_job(transcription, summary)
          render(
            turbo_stream: turbo_stream.replace(
              TranscriptionSummaryComponent.id(transcription:),
              TranscriptionSummaryComponent.new(transcription:).render_in(view_context)
            ),
            status: :created
          )
        else
          flash.now.alert = 'Unable to create transcription summary'
          render turbo_stream: turbo_stream.update('alert-stream', FlashMessageComponent.new(flash:, record: summary)),
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def enqueue_transcription_summary_job(transcription, summary)
    TranscriptionSummaryJob.perform_async(current_user.id, transcription.id)
    summary.queued!
  end

  def transcription_summary_params
    params.require(:transcription_summary).permit(:transcription_id)
  end
end
