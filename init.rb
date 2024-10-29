require_relative 'lib/hooks'
require_relative 'app/helpers/category_assignment_calendars_helper'
require_relative 'app/models/project_patch'
Project.send(:include, ProjectPatch)
require_relative 'app/models/issue_category_patch'
IssueCategory.send(:include, IssueCategoryPatch)
require_relative 'app/models/issue_patch'
Issue.send(:include, IssuePatch) unless Issue.included_modules.include?(IssuePatch)

Redmine::Plugin.register :category_assignment_calendar do
  name 'Category Assignment Calendar'
  author 'Ваше Имя'
  description 'Хранит и отображает календарь назначений в категориях задач проектов с возможностью установления периодичности.'
  version '0.0.1'
  url 'https://your-repository-url.com'
  author_url 'https://your-website.com'

  project_module :issue_tracking do
    permission :view_assignment_calendar, { category_assignment_calendars: [:index] }, public: true
    permission :manage_assignment_calendar, { category_assignment_calendars: [:new, :create, :edit, :update, :destroy] }, require: :member
  end

  menu :project_menu, :category_assignment_calendars, { controller: 'category_assignment_calendars', action: 'index' }, caption: 'Назначения Календаря', after: :issues, :param => :project_id
end
