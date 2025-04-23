require 'bitcoin'

module Services
  
  class BitcoinExt
    def initialize
      Bitcoin.chain_params = :signet
    end

  end
  
end