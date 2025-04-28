require "bitcoin"
require "httparty"

  # module Services

  class Mempool
    MEMPOOL_SPACE_URL = "https://mempool.space/signet/api/".freeze

    def initialize
      Bitcoin.chain_params = :signet
    end

    def get_last_tx(addr)
      path = "#{MEMPOOL_SPACE_URL}address/#{addr}/txs"
      response = HTTParty.get(path)
      j = JSON.parse(response.body)
      last = j.kind_of?(Array) ? j.first : j
      last["txid"]
    end

    def get_balance(addr)
      path = "https://mempool.space/signet/api/address/#{addr}/txs"
      response = HTTParty.get(path)
      j = JSON.parse(response.body)
      total = 0
      if j.kind_of?(Array)
        j.reverse.each do |e|
          unless e.nil?
            vin_sum = e["vin"].filter { |q| q["prevout"]["scriptpubkey_address"] == addr }.sum { |k| k["prevout"]["value"] || 0 }.to_i
            vout_sum = e["vout"].filter { |k| k["scriptpubkey_address"] == addr }.sum { |k| k["value"] || 0 }.to_i
            total += (vout_sum - vin_sum)
          end
        end
      end
      total
    end
  end

# end
