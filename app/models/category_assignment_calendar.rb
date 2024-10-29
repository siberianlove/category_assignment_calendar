class CategoryAssignmentCalendar < ActiveRecord::Base
  belongs_to :project
  belongs_to :issue_category
  belongs_to :principal, :foreign_key => 'user_id'

  serialize :recurrence_rule, IceCube::Schedule

  # validate :valid_recurrence_rule
  validates :project_id, :issue_category_id, :principal, presence: true
  validate :end_date_after_start_date

  before_save :set_recurrence_rule


  def next_occurrence
    occ = recurrence_rule.next_occurrence
    if occurs_now?
      enumerate_occurrences(IceCube::TimeUtil.now, IceCube::TimeUtil.now, options).first
    elsif occ == nil or event_ends_after_date == nil or occ.start_time > IceCube::TimeUtil.end_of_date(event_ends_after_date)
      nil
    else
      occ
    end
  end
  def occurs_now?
    recurrence_rule.occurs_at?(IceCube::TimeUtil.now)
  end

  def is_active?
    event_ends_after_date == nil or event_ends_after_date >= Date.today
  end

  def end_date_after_start_date
    if !all_day? && (event_end_date_time < event_start_date_time)
      errors.add(:event_end_date_time, 'должна быть после даты начала')
    end
  end

  def set_recurrence_rule
    if recurring
      rule = case frequency
             when 'Ежедневно'
               IceCube::Rule.daily(interval)
             when 'Еженедельно'
               IceCube::Rule.weekly(interval, :monday).day(weekdays.map(&:to_sym))
             when 'Ежемесячно'
               IceCube::Rule.monthly(interval)
             when 'Ежегодно'
               IceCube::Rule.yearly(interval)
             else
               nil
             end
      if all_day?
        self.recurrence_rule = IceCube::Schedule.new(IceCube::TimeUtil.beginning_of_date(event_date), end_time: IceCube::TimeUtil.end_of_date(event_date)) do |s|
          s.add_recurrence_rule rule if rule
        end
      else
        self.recurrence_rule = IceCube::Schedule.new(event_start_date_time, end_time: event_end_date_time) do |s|
          s.add_recurrence_rule rule if rule
        end
      end

    else
      self.recurrence_rule = nil
    end
  end

  def weekdays
    (self[:weekdays] || []).map(&:to_sym)
  end

  private

  # def valid_recurrence_rule
  #   if recurrence_rule.present?
  #     begin
  #       IceCube::Rule.from_yaml(recurrence_rule)
  #     rescue Exception => e
  #       errors.add(:recurrence_rule, "Некорректное правило повторения: #{e}")
  #     end
  #   end
  # end
end