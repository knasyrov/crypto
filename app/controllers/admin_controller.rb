class AdminController < ApplicationController
  http_basic_authenticate_with name: "admin", password: "admin"

  def index
    @transactions = Transaction.all
  end
end
