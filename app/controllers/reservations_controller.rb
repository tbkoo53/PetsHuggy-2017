# coding: utf-8
class ReservationsController < ApplicationController

  def create
    @listing = Listing.find(params[:listing_id])

    if current_user == @listing.user
      selectedDates = params[:reservation][:selectedDates].split(",")
      reservationsByme = @listing.reservations.where(user_id: current_user.id)
      oldSelectedDates = []

      reservationsByme.each do |reservation|
        oldSelectedDates.push(reservation.start_date)
      end

      if oldSelectedDates
        oldSelectedDates.each do |date|
          @reservation = current_user.reservations.where(start_date: date, end_date: date)
          @reservation.destroy_all
        end
      end

      createDates = selectedDates
      if createDates
        createDates.each do |date|
          current_user.reservations.create(:listing_id => @listing.id, :start_date => date, :end_date => date)
        end
      end

      redirect_to :back, notice: "更新しました。"
    else

    @reservation = current_user.reservations.create(reservation_params)
    redirect_to @reservation.listing, notice: "予約が完了しました。"
    end
  end

  def setdate
    listing = Listing.find(params[:listing_id])
    today = Date.today
    reservations = listing.reservations.where("start_date >= ? OR end_date >= ?", today, today )
    render json: reservations
  end

  def duplicate
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    result = {
      duplicate: is_duplicate(start_date, end_date)
    }

    render json: result
  end

  private
  def reservation_params
    params.require(:reservation).permit(:start_date, :end_date, :price_pernight, :total_price, :listing_id)
  end

  def is_duplicate(start_date, end_date)
    listing = Listing.find(params[:listing_id])

    check = listing.reservations.where("? < start_date AND end_date < ?", start_date, end_date)
    check.size > 0? true : false
  end
end
