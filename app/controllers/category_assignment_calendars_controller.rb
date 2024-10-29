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
      redirect_to project_category_assignment_calendars_path(@project), notice: 'Календарь назначений успешно создан.'
    else
      logger.error "DEBUG: Ошибки сохранения: #{@calendar.errors.full_messages.join(", ")}"
      logger.error "DEBUG: Параметры: #{calendar_params.inspect}"
      flash[:error] = 'Не удалось создать календарь назначений. Проверьте введенные данные.'
      render :new
    end
  end

  def edit
    @calendar = @project.category_assignment_calendars.find(params[:id])
  end

  def update
    @calendar = @project.category_assignment_calendars.find(params[:id])
    if @calendar.update(calendar_params)
      redirect_to project_category_assignment_calendars_path(@project), notice: 'Календарь назначений успешно обновлен.'
    else
      logger.error "DEBUG: Ошибки сохранения: #{@calendar.errors.full_messages.join(", ")}"
      logger.error "DEBUG: Параметры: #{calendar_params.inspect}"
      flash[:error] = "Не удалось обновить календарь назначений. Проверьте введенные данные. Ошибки сохранения: #{@calendar.errors.full_messages.join(", ")}"
      render :edit
    end
  end

  def destroy
    @calendar = @project.category_assignment_calendars.find(params[:id])
    @calendar.destroy
    redirect_to project_category_assignment_calendars_path(@project), notice: 'Календарь назначений успешно удалён.'
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def calendar_params
    params.require(:category_assignment_calendar).permit(:issue_category_id, :user_id, :event_start_date_time, :event_date, :event_end_date_time, :event_ends_after_date, :all_day, :recurring, :frequency, :interval, weekdays: [])
  end
end