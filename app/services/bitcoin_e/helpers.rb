module BitcoinE
  module Helpers
    def get_transactions_for_in(addr)
      path = "https://mempool.space/signet/api/address/#{addr}/txs"
      response = HTTParty.get(path) 
      j = JSON.parse(response.body)
    
      if j.kind_of?(Array) && !j.first.nil?
        j.first['vout'].each_with_index do |e, i|
          if e['scriptpubkey_address'] == addr
            return [i, e['value']]
          end
        end
      end
      [nil, nil]
    end

    def get_last_tx(addr)
      path = "https://mempool.space/signet/api/address/#{addr}/txs"
      response = HTTParty.get(path) 
      j = JSON.parse(response.body)
      last = j.kind_of?(Array) ? j.first : j
      last['txid']
    end

    def generate_word_list
      # Bitcoin.chain_params = :signet

      mnemonic = Bitcoin::Mnemonic.new('english')
      entropy = SecureRandom.hex(32)
      mnemonic.to_mnemonic(entropy)
    end

    def seed_from_word_list(word_list)
      # Bitcoin.chain_params = :signet

      mnemonic = Bitcoin::Mnemonic.new('english')
      mnemonic.to_seed(word_list)
    end
  end
end