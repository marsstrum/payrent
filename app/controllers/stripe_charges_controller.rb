class StripeChargesController < ApplicationController
	
	 def new
	 	@unit = current_user.unit
    @unit.security_paid? ? security = 0 : security = @unit.security_charge
    @total_paid = ((@unit.rent_charge + current_user.unit.latest_utility_charge + security)*100).round
	   @stripe_btn_data = {
	     key: "#{ Rails.configuration.stripe[:publishable_key] }",
	     description: "Rent Payment - #{current_user.name}",
	     amount: @total_paid
	   }
 	end

	def create
 		@unit = current_user.unit
    @unit.security_paid? ? security = 0 : security = @unit.security_charge
    @total_paid = ((@unit.rent_charge+current_user.unit.latest_utility_charge + security)*100).round
   # Creates a Stripe Customer object, for associating
   # with the charge
   customer = Stripe::Customer.create(
     email: current_user.email,
     card: params[:stripeToken]
   )
 
   # Where the real magic happens
   charge = Stripe::Charge.create(
     customer: customer.id, # Note -- this is NOT the user_id in your app
     amount: @total_paid,
     description: "Rent Charges - #{current_user.email}",
     currency: 'usd'
   )
 	#Write payment details to the payments table
   @payment = Payment.create(total_paid: @total_paid/100, rent_paid: @unit.rent_charge, security_paid: security, user_id: current_user.id, unit_id: current_user.unit.id, utility_charge_id: current_user.unit.utility_charges.last.id, pay_type: "Credit"  )
   @payment.save

   #if security deposit is paid switch boolean to true
   if security > 0
    @security_update = Unit.where(user_id: current_user).first
    paid_security = @security_update.update(security_paid: true)
   end

   #paid boolean is 'false' by default - change to 'true'
   @current_due_date = PaidRent.where(paid: false, unit_id: current_user.unit.id).first.date_due
   @paid_state = PaidRent.where(date_due: @current_due_date, unit_id: current_user.unit.id).first
   @switch_paid = @paid_state.update(paid: true)

    #is_paid boolean for UtilityCharge table is 'false' by default - change to 'true'
    if current_user.unit.latest_utility_charge > 0
      @utility_not_paid = UtilityCharge.where(is_paid: false, unit_id: current_user.unit.id).last
      @utility_is_paid = @utility_not_paid.update(is_paid: true)
    end
    
   flash[:success] = "Thank you for your payment, #{current_user.email}!"
   redirect_to payments_path
 
 # Stripe will send back CardErrors, with friendly messages
 # when something goes wrong.
 # This `rescue block` catches and displays those errors.
 rescue Stripe::CardError => e
   flash[:error] = e.message
   redirect_to new_stripe_charge_path
 end
end
