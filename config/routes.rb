RedmineApp::Application.routes.draw do
  resources :projects do
    resources :category_assignment_calendars, controller: 'category_assignment_calendars'
  end
end