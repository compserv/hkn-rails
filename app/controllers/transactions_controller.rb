class TransactionsController < ApplicationController
  respond_to :json, :html

  def new
    @amount       = params[:amount]
    @company_id   = params[:company_id]
    @description  = params[:description]
  end

  def create
    charge = Stripe::Charge.create(
      :card         => params[:stripeToken],
      :amount       => params[:amount],
      :description  => params[:description],
      :currency     => 'usd'
    )

    transaction_params = {}
    transaction_params[:company]      = Company.find_by_id(params[:company_id])
    transaction_params[:amount]       = charge.amount
    transaction_params[:charge_id]    = charge.id
    transaction_params[:description]  = charge.description

    @transaction = Transaction.create(transaction_params)
    respond_with @transaction # Probably want this to go to some receipt page?

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to transactions_path
  end

end
