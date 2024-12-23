class CategoryAssignmentCalendarsController < ApplicationController
  unloadable
  before_action :find_project
  before_action :authorize

  def index
    @calendars = @project.category_assignment_calendars
  end

  def show
    @calendar = @project.category_assignment_calendars.find(params[:id])
  end

  def new
    @calendar = @project.category_assignment_calendars.new
  end

  def create
    @calendar = @project.category_assignment_calendars.new(calendar_params)

    if @calendar.save
      redirect_to project_category_assignment_calendars_path(@project), notice: ::I18n.t(:category_assignment_calendar_create_succeeded)
    else
      flash[:error] = ::I18n.t(:category_assignment_calendar_create_error) + " #{@calendar.errors.full_messages.join(", ")}"
      render :new
    end
  end

  def edit
    @calendar = @project.category_assignment_calendars.find(params[:id])
  end

  def update
    @calendar = @project.category_assignment_calendars.find(params[:id])
    if @calendar.update(calendar_params)
      redirect_to project_category_assignment_calendars_path(@project), notice: ::I18n.t(:category_assignment_calendar_update_succeeded)
    else
      flash[:error] = ::I18n.t(:category_assignment_calendar_update_error) + " #{@calendar.errors.full_messages.join(", ")}"
      render :edit
    end
  end

  def destroy
    @calendar = @project.category_assignment_calendars.find(params[:id])
    if @calendar.destroy
      redirect_to project_category_assignment_calendars_path(@project), notice: ::I18n.t(:category_assignment_calendar_delete_succeeded)
    else
      flash[:error] = ::I18n.t(:category_assignment_calendar_delete_error) + " #{@calendar.errors.full_messages.join(", ")}"
      render :index
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def calendar_params
    params.require(:category_assignment_calendar).permit(:issue_category_id, :user_id, :event_start_date_time, :event_date, :event_end_date_time, :event_ends_after_date, :all_day, :recurring, :frequency, :interval, weekdays: [])
  end
end