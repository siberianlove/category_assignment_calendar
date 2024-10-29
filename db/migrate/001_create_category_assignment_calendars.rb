class CreateCategoryAssignmentCalendars < ActiveRecord::Migration[6.0]
  def change
    create_table :category_assignment_calendars do |t|
      t.references :project, null: false, foreign_key: true
      t.references :issue_category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :event_date
      t.column :event_start_date_time, :datetime
      t.column :event_end_date_time, :datetime
      t.date :event_ends_after_date
      t.boolean :recurring, default: false
      t.boolean :all_day, default: false
      t.string :recurrence_rule
      t.string :frequency
      t.integer :interval
      t.string :weekdays, array: true, default: []
      t.timestamps
    end
  end
end