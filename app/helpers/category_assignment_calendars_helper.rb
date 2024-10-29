module CategoryAssignmentCalendarsHelper
  def render_calendar(calendars)
    content_tag :div, id: 'assignment-calendar' do
      calendars.each do |calendar|
        concat(content_tag(:p, "#{calendar.issue_category.name}: #{calendar.user.name} с #{calendar.start_date} по #{calendar.end_date}"))
      end
    end
  end
end