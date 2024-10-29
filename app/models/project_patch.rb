module ProjectPatch
  extend ActiveSupport::Concern

  included do
    has_many :category_assignment_calendars, dependent: :destroy
  end
end