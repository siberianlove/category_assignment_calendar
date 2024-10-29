class Hooks < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom, partial: 'category_assignment_calendars/calendar'
end