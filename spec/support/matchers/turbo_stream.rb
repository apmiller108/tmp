RSpec::Matchers.define :have_turbo_stream do |action:, target: nil, targets: nil, count: 1|
  match do |_actual|
    assert_turbo_stream(action:, target:, targets:, count:, &block_arg).present?
  end
end
