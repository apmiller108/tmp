class TranscriptionJob < ApplicationRecord
  belongs_to :active_storage_blob, class_name: 'ActiveStorage::Blob'
  has_one :transcription, dependent: :destroy

  enum :status, {
    created: 'created',
    queued: 'queued',
    in_progress: 'in_progress',
    failed: 'failed',
    completed: 'completed'
  }

  validates :status, inclusion: { in: statuses.values, message: "%<value>s must be one of #{statuses.values}" }
  validates_with ReferencesAudioBlobValidator

  scope :unfinished, -> { where.not(status: %i[failed completed]) }

  def self.create_for(transcription_service:)
    create!(request: transcription_service.params,
            remote_job_id: transcription_service.job_id,
            status: transcription_service.status,
            active_storage_blob: transcription_service.blob)
  end

  def results
    return if response.blank?

    response.dig('results', 'transcripts')[0]['transcript']
  end

  # TODO: refactor this
  # TODO: determine from the request is results are diarized return otherwize
  def diarized_results
    response.dig('results', 'items')
            .map { |i| { i['speaker_label'] => i['alternatives'][0]['content'] } }
            .each_with_object([]) do |item, a|
      if a.empty?
        a.push(item)
      else
        prev_speech = a.last
        prev_speaker = prev_speech.keys.first
        if prev_speaker == item.keys.first
          prev_speech[prev_speaker] += (item[prev_speaker] =~ /\A[[:punct:]]\z/ ? item[prev_speaker] : " #{item[prev_speaker]}")
        else
          a.push(item)
        end
      end
    end
  end
end
