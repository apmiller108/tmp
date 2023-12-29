class Transcription
  class SpeakerContent
    class Item
      attr_reader :item_data
      attr_accessor :content

      # @param [Hash] AWS transcription service item:
      # { 'type' => 'pronunciation',
      #   'end_time' => '1.509',
      #   'start_time' => '1.169',
      #   'alternatives' => [{ 'content' => 'crucial', 'confidence' => '0.998' }],
      #   'speaker_label' => 'spk_0' }
      def initialize(item_data)
        @item_data = item_data
        @content = item_data['alternatives'][0]['content']
      end

      def speaker
        item_data['speaker_label']
      end

      # Humanized speaker name
      #
      # @param [String] spk_0, spk_1, ...etc
      # @return [String] Speaker 1, Speaker 2, ...etc
      def speaker_humanized
        speaker_num = speaker.split('_').last.to_i + 1
        "Speaker #{speaker_num}"
      end

      def speaker_same_as?(other)
        speaker == other.speaker
      end

      def combinable_value
        if punctuation?
          content
        else
          " #{content}"
        end
      end

      def punctuation?
        item_data['type'] == 'punctuation'
      end

      def combine_with(other)
        self.content += other.combinable_value
      end

      def to_text
        "#{speaker_humanized}: #{content}"
      end
    end
  end
end
