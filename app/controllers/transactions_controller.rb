class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show ]

  def index
    @transactions = Transaction.all
  end

  def show
  end

  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    #@transaction.fee_percent = params[:fee_percent]
    #@transaction.fee_value = params[:fee_value]
    puts "--->", @transaction.inspect

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: "Transaction was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end


  private
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def transaction_params
      params.fetch(:transaction, {}).permit(:in_value,
                                            :in_addr,
                                            :out_addr,
                                            :change_addr,
                                            :fee_value)
    end
end
