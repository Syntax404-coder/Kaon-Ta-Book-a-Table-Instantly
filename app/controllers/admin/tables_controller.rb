module Admin
  class TablesController < ApplicationController
    before_action :require_admin

    def edit
      @table = Table.find(params[:id])
    end

    def update
      @table = Table.find(params[:id])

      new_capacity = table_params[:capacity].to_i
      old_capacity = @table.capacity
      capacity_difference = new_capacity - old_capacity

      # Calculate new remaining seats
      # Current Usage = Old Capacity - Old Remaining
      # New Remaining = New Capacity - Current Usage
      # Algebraic simplification: New Remaining = New Capacity - (Old Capacity - Old Remaining)
      # = New Capacity - Old Capacity + Old Remaining
      # = Difference + Old Remaining

      new_remaining_seats = @table.remaining_seats + capacity_difference

      if new_remaining_seats < 0
        flash[:alert] = "Cannot reduce capacity below the number of current reservations!"
        render :edit, status: :unprocessable_entity
        return
      end

      if @table.update(capacity: new_capacity, remaining_seats: new_remaining_seats)
        redirect_to admin_dashboard_path(date: @table.start_time.to_date), notice: "Capacity updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def table_params
      params.require(:table).permit(:capacity)
    end
  end
end
