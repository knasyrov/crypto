require 'bitcoin'
require 'httparty'

class AddressesController < ApplicationController
  def index
=begin
    Bitcoin.chain_params = :signet
    mnemonic = Bitcoin::Mnemonic.new('english')
    
    word_list = %w(crystal decline october ask property climb correct auction outdoor voyage enable shallow skin marble link sorry tonight cycle grab okay roast brush theory joke)
    seed = mnemonic.to_seed(word_list)
    @master_key = Bitcoin::ExtKey.generate_master(seed)

    @addresses = []

    (0..20).each do |i|
      a = @master_key.derive(84, true).derive(0, true).derive(i)
      path = "m/84/0/#{i}"
      addr = a.key.to_addr
      wif = a.key.to_wif
      Address.find_or_create_by(eid: addr, path: path, direction: 0, wif: wif) do |e|
        e.balance = get_balance(addr)
      end
    end

    (0..10).each do |i|
      a = @master_key.derive(84, true).derive(1, true).derive(i)
      path = "m/84/1/#{i}"
      addr = a.key.to_addr
      wif = a.key.to_wif
      Address.find_or_create_by(eid: addr, path: path, direction: 1, wif: wif) do |e|
        e.balance = get_balance(addr)
      end
    end

    @addresses = Address.all
=end
    @addresses = Address.all
  end

  def show
  end

  private

  def get_balance(addr)
    path = "https://mempool.space/signet/api/address/#{addr}/txs"
    response = HTTParty.get(path) 
    j = JSON.parse(response.body)
    total = 0
    if j.kind_of?(Array)
      j.reverse.each do |e|
        unless e.nil?
          vin_sum = e['vin'].filter {|q| q['prevout']['scriptpubkey_address'] == addr }.sum { |k| k['prevout']['value'] || 0 }.to_i
          vout_sum = e['vout'].filter { |k| k['scriptpubkey_address'] == addr }.sum { |k| k['value'] || 0 }.to_i
          total += (vout_sum - vin_sum)
        end
      end
    end
    total
  end
end