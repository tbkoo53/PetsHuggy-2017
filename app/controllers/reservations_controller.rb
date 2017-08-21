# coding: utf-8
class ReservationsController < ApplicationController

  def create
    @reservation = current_user.reservations.create(reservation_params)

    redirect_to @reservation.listing, notice: "予約が完了しました。"
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
