class TranscriptionsController < ApplicationController
  def index
    @transcription = current_user.transcriptions.find_by!(transcription_job_id: params[:transcription_job_id])

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end
end
