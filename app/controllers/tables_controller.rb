class TablesController < ApplicationController
  before_action :require_login

  def index
    # Redirect admin to dashboard
    if current_user.admin?
      redirect_to admin_dashboard_path
      return
    end

    # Get current Manila time
    manila_now = Time.now.in_time_zone("Asia/Manila")

    # Default to Manila date
    @today_date = manila_now.to_date
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : @today_date

    # Use timezone-aware range query
    day_start = @selected_date.beginning_of_day
    day_end = @selected_date.end_of_day

    @tables = Table.where(start_time: day_start..day_end).order(:start_time)

    # Filter past slots if strictly viewing today
    if @selected_date == @today_date
      # Create a cutoff time that matches the stored UTC format but represents Manila time
      # e.g., if Manila is 18:00, we want to hide slots < 18:00 stored as UTC
      cutoff_time = Time.utc(manila_now.year, manila_now.month, manila_now.day, manila_now.hour, manila_now.min, manila_now.sec)
      @tables = @tables.where("start_time > ?", cutoff_time)
    end
  end
end
