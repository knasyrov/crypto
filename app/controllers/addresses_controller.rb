require "bitcoin"
require "httparty"

class AddressesController < ApplicationController
  def index
    @addresses = Address.all
  end

  def show
  end

  def reload
    BitcoinE::Client.update_balance
    @addresses = Address.all
    render action: :index
  end
end
