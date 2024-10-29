module IssueCategoryPatch
  extend ActiveSupport::Concern

  included do
    has_many :category_assignment_calendars, dependent: :destroy
    accepts_nested_attributes_for :category_assignment_calendars, allow_destroy: true
  end
end
