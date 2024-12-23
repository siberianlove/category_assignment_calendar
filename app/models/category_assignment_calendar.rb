class CategoryAssignmentCalendar < ActiveRecord::Base
  belongs_to :project
  belongs_to :issue_category
  belongs_to :principal, :foreign_key => 'user_id'

  serialize :recurrence_rule, IceCube::Schedule

  # validate :valid_recurrence_rule
  validates :project_id, :issue_category_id, :principal, presence: true
  validate :v_end_date_after_start_date, :v_event_dates, :v_interval

  before_save :set_recurrence_rule

  def v_end_date_after_start_date
    if !all_day? && event_start_date_time != nil && event_end_date_time != nil && (event_end_date_time < event_start_date_time)
      errors.add(:event_end_date_time, ::I18n.t('category_assignment_calendar_end_should_be_greater_than_start'))
    end
  end

  def v_event_dates
    if all_day? && event_date == nil
      errors.add(:event_date, ::I18n.t('activerecord.errors.messages.blank'))
    end
    unless all_day?
      if event_start_date_time == nil
        errors.add(:event_start_date_time, ::I18n.t('activerecord.errors.messages.blank'))
      end
      if event_end_date_time == nil
        errors.add(:event_end_date_time, ::I18n.t('activerecord.errors.messages.blank'))
      end
    end
  end

  def v_interval
    if recurring? && interval == nil
      errors.add(:interval, ::I18n.t('activerecord.errors.messages.blank'))
    end
  end

  def next_occurrence
    t_now = IceCube::TimeUtil.now
    if recurring?
      occ = recurrence_rule.next_occurrence
      if occurs_now?
        result = recurrence_rule.next_occurrence
        if all_day?
          IceCube::TimeUtil.ensure_date(result)
        else
          result
        end
      elsif occ.nil?
        nil
      elsif event_ends_after_date && occ.start_time > IceCube::TimeUtil.end_of_date(event_ends_after_date)
        nil
      else
        occ
      end
    elsif all_day? && IceCube::TimeUtil.beginning_of_date(event_date) > t_now
      event_date
    elsif !all_day? && event_start_date_time > t_now
      Occurrence(event_start_date_time, event_end_date_time)
    else
      nil
    end
  end

  def occurs_now?
    t_now = IceCube::TimeUtil.now
    if !is_active?
      false
    elsif recurring
      if all_day?
        return recurrence_rule.occurs_on?(t_now)
      else
        if recurrence_rule.next_occurrence.cover?(t_now) || recurrence_rule.previous_occurrence(t_now).cover?(t_now)
          return true
        end
        # if recurrence_rule.occurs_on?(Date.today)
        #   return recurrence_rule.occurrences_between(IceCube::TimeUtil.beginning_of_date(t_now), IceCube::TimeUtil.end_of_date(t_now)).any? { |o| o.cover?(t_now) }
        # else
        #   return false
        # end
      end
    else
      if all_day?
        return event_date == Date.today
      else
        return event_start_date_time < t_now && t_now < event_end_date_time
      end
    end
  end

  def is_active?
    event_ends_after_date == nil || event_ends_after_date > Date.today
  end

  def set_recurrence_rule
    if recurring
      rule = case frequency
             when ::I18n.t('category_assignment_calendar_daily')
               IceCube::Rule.daily(interval)
             when ::I18n.t('category_assignment_calendar_weekly')
               IceCube::Rule.weekly(interval).day(weekdays)
             when ::I18n.t('category_assignment_calendar_monthly')
               IceCube::Rule.monthly(interval)
             when ::I18n.t('category_assignment_calendar_yearly')
               IceCube::Rule.yearly(interval)
             else
               nil
             end

      if all_day? && event_date != nil
        self.recurrence_rule = IceCube::Schedule.new(IceCube::TimeUtil.beginning_of_date(event_date), end_time: IceCube::TimeUtil.end_of_date(event_date)) do |s|
          s.add_recurrence_rule(rule) if rule
        end
      elsif !all_day? && event_start_date_time != nil && event_end_date_time != nil
        self.recurrence_rule = IceCube::Schedule.new(IceCube::TimeUtil.build_in_zone(event_start_date_time, Time.now), end_time: IceCube::TimeUtil.build_in_zone(event_end_date_time, Time.now)) do |s|
          s.add_recurrence_rule(rule) if rule
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