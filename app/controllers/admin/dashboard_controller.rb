module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
      manila_now = Time.now.in_time_zone("Asia/Manila")
      @selected_date = params[:date] ? Date.parse(params[:date]) : manila_now.to_date
      @cutoff_time = Time.utc(manila_now.year, manila_now.month, manila_now.day, manila_now.hour, manila_now.min, manila_now.sec)

      @reservations = Reservation.joins(:table, :user)
                                 .includes(:table, :user)
                                 .order("tables.start_time DESC")

      @tables = Table.where(start_time: @selected_date.all_day).order(:start_time)
    end

    def toggle_slot
      @table = Table.find(params[:id])
      @table.update!(is_closed: !@table.is_closed)
      redirect_to admin_dashboard_path, notice: "Slot #{@table.is_closed ? 'closed' : 'opened'} successfully."
    end
  end
end
