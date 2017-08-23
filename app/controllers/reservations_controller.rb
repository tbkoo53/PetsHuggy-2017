# coding: utf-8
class ReservationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @reservations = Reservation.where(self_booking: nil)
  end

  def new
    @listing = Listing.find(params[:listing_id])
    @user = current_user

    @start_date =  params[:reservation][:start_date]
    @end_date =  params[:reservation][:end_date]
    @price_pernight =  params[:reservation][:price_pernight]
    @total_price =  params[:reservation][:total_price]
  end

  def reserved
    @listings = current_user.listings
  end

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
          current_user.reservations.create(:listing_id => @listing.id, :start_date => date, :end_date => date, :self_booking => true)
        end
      end

      redirect_to :back, notice: "更新しました。"
    else

      #stripe
      user = @listing.user

      # Charge
      amount = params[:reservation][:total_price]

      #fee
      fee = (amount.to_i * 0.1).to_i

      # Calculate the fee amount that goes to the application.
      # docs https://stripe.com/docs/connect/payments-fees
      begin
        charge_attrs = {
            amount: amount,
            currency: user.currency,
            source: params[:token],
            description: "Test Charge via Stripe Connect",
            application_fee: fee
        }

        # Use the platform's access token, and specify the
        # connected account's user id as the destination so that
        # the charge is transferred to their account.
        charge_attrs[:destination] = user.stripe_user_id

        charge = Stripe::Charge.create( charge_attrs )

        #have to edit view template to show html in flash
        flash[:notice] = "Charged successfully!"

      rescue Stripe::CardError => e
        error = e.json_body[:error][:message]
        flash[:error] = "Charge failed! #{error}"
      end


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
