class Transcription
  class SpeakerContent
    def initialize(speaker_data)
      @speaker_data = speaker_data
    end

    def content
      @content ||= @speaker_data.map { |i| Item.new(i) }
    end

    def speakers
      content.map(&:speaker_humanized).uniq
    end

    def squash
      content.each_with_object([]) do |item, squashed|
        squashed.push(item) and next if squashed.empty?

        prev_item = squashed.last

        if prev_item.speaker_same_as?(item)
          prev_item_index = squashed.size - 1
          squashed[prev_item_index] = prev_item.combine_with(item)
        else
          squashed.push(item)
        end
      end
    end
  end
end
