FactoryBot.define do
  factory :generate_text_preset do
    name { 'Futurist' }
    description { 'Discuss science fiction scenarios and associated challenges and considerations.' }
    system_message do
      'Your task is to explore a science fiction scenario and discuss the potential challenges and '\
      'considerations that may arise. Briefly describe the scenario, identify the key technological,'\
      'social, or ethical issues involved, and encourage the user to share their thoughts on how '\
      'these challenges might be addressed.'
    end
    temperature { 1 }
  end
end
