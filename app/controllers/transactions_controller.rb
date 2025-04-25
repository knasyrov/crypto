class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show send_tr ]

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

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: "Transaction was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def send_tr
    puts 'SEND SEND'
    puts id, @transaction
    #hex = BitcoinE::Client.transaction(@transaction)
    #puts "curl -X POST -sSLd \"#{hex}\" \"https://mempool.space/signet/api/tx\""
    #puts "TXID = #{txid}"
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
