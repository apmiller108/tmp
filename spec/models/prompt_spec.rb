require 'rails_helper'

RSpec.describe Prompt do
  describe 'parameterize' do
    it 'returns a hash containing the text and weight properties' do
      prompt = build :prompt
      expect(prompt.parameterize).to eq('text' => prompt.text, 'weight' => prompt.weight)
    end
  end
end
