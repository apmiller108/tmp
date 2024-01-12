class TranscriptionsController < ApplicationController
  def index
    @transcription = current_user.transcriptions.find_by!(transcription_job_id: params[:transcription_job_id])

    respond_to(&:turbo_stream)
  end
end
