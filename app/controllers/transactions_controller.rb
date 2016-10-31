require 'securerandom'

class TransactionsController < ApplicationController
  respond_to :json, :html

  def new
    @amount       = params[:amount].to_i rescue 0
    @usd_amount   = @amount.to_i / 100.0
    @description  = params[:description]
  end

  def show
    @transaction = Transaction.find(params[:id])
    @usd_amount  = @transaction.amount.to_i / 100.0
    redirect_to :root, error: "You are not authorized to view that." unless
        @transaction.receipt_secret == params[:receipt_secret]
  end

  def create
    charge = Stripe::Charge.create(
      card:         params[:stripeToken],
      amount:       params[:amount],
      description:  params[:description],
      currency:     'usd'
    )

    receipt_secret = SecureRandom.base64

    transaction_params = {}
    transaction_params[:amount]         = charge.amount
    transaction_params[:charge_id]      = charge.id
    transaction_params[:description]    = charge.description
    transaction_params[:receipt_secret] = receipt_secret

    @transaction = Transaction.create(transaction_params)
    redirect_to transaction_path(@transaction,
        { receipt_secret: receipt_secret })

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to transactions_path
  end

end
