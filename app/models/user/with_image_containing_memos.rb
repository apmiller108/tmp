class User
  class WithImageContainingMemos < ApplicationQuery
    def initialize(relation = User.all)
      super(relation)
    end

    def resolve(image_count: 1)
      User.with(
        with_image_memos: Memo.where(image_attachment_count: image_count..)
                              .select(:user_id)
                              .distinct
      ).joins(:with_image_memos)
    end
  end
end
