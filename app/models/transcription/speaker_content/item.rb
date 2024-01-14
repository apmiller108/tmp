class Transcription
  class SpeakerContent
    class Item
      attr_reader :item_data
      attr_accessor :item_content

      # @param [Hash] AWS transcription service item:
      # { 'type' => 'pronunciation',
      #   'end_time' => '1.509',
      #   'start_time' => '1.169',
      #   'alternatives' => [{ 'content' => 'crucial', 'confidence' => '0.998' }],
      #   'speaker_label' => 'spk_0' }
      def initialize(item_data)
        @item_data = item_data
        @item_content = item_data['alternatives'][0]
      end

      def content
        item_content['content']
      end

      def confidence
        item_content['confidence'].to_f
      end

      def speaker
        item_data['speaker_label']
      end

      # Humanized speaker name
      #
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

      # Combines two items into a single Item of type `combined`.
      #
      # @param [SpeakerContent::Item]
      # @return [SpeakerContent::Item]
      def combine_with(other)
        raise ArgumentError, 'Speakers must match in order to combine items' if other.speaker != speaker

        combined_data = {
          'type' => 'combined',
          'end_time' => [end_time, other.end_time].max.to_s,
          'start_time' => [start_time, other.start_time].min.to_s,
          'alternatives' => [
            {
              'content' => content + other.combinable_value,
              'confidence' => ((confidence + other.confidence) / 2.0).to_s
            }
          ],
          'speaker_label' => speaker
        }
        self.class.new(combined_data)
      end

      def to_text
        "#{speaker_humanized}: #{content}"
      end

      def end_time
        item_data['end_time'].to_f
      end

      def start_time
        item_data['start_time'].to_f
      end
    end
  end
end
