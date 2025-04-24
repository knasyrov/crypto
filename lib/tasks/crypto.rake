#require 'bitcoinrb'

namespace :crypto do
  desc "Import from coingecko available coin types"
  task create_wallet: :environment do
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
  end
end