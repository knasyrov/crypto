require 'bitcoin'
require 'httparty'

module Services
  
  class Mempool
    def initialize
      Bitcoin.chain_params = :signet
    end
  end
  
end