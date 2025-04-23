require 'bitcoin'
require 'httparty'

module BitcoinE
  
  class Client
    attr_reader :master_key


    def initialize
      Bitcoin.chain_params = :signet
    end


    def generate
      Bitcoin.chain_params = :signet
      mnemonic = Bitcoin::Mnemonic.new('english')
      entropy = SecureRandom.hex(32)
      word_list = mnemonic.to_mnemonic(entropy)
      puts "Your word list: ", word_list.join(' ')
    
      word_list = %w(crystal decline october ask property climb correct auction outdoor voyage enable shallow skin marble link sorry tonight cycle grab okay roast brush theory joke)
      seed = mnemonic.to_seed(word_list)
      @master_key = Bitcoin::ExtKey.generate_master(seed)
      wif = @master_key.key.to_wif
      #key = @master_key.derive(84, true).derive(0, true).derive(0, true).derive(0).derive(0)
      e = @master_key.derive(84, true).derive(0, true).derive(0, true)
      q = e.key.to_wif

      t = {
        master_key: @master_key.to_s,
        wif: wif,
        ext_pub: @master_key.ext_pubkey.pubkey,
        base58: @master_key.to_base58,
        words: word_list
      }

      File.open('out.json', 'w') do |f|
        f.write(t.to_json)
      end

      puts 'ALL IN'

      puts "ПРИЕМ"
      get_coins(@master_key.derive(84, true).derive(0, true).ext_pubkey.to_base58, 20)

      puts "OUTPUT"
      get_coins(@master_key.derive(84, true).derive(1, true).ext_pubkey.to_base58, 10)

      (0..20).each do |i|
        #puts "#{i} = #{@master_key.derive(84, true).derive(0, true).derive(i).key.to_wif}"
        a = @master_key.derive(84, true).derive(0, true).derive(i)
        addr = a.key.to_addr
        #addr = Bitcoin::Key.new(pubkey: pub_key, key_type: Bitcoin::Key::TYPES[:p2wpkh])
        puts "p2wpkh:#{a.key.to_wif}"# -> #{addr}"
      end

      (0..10).each do |i|
        #puts "#{i} = #{@master_key.derive(84, true).derive(0, true).derive(i).key.to_wif}"
        a = @master_key.derive(84, true).derive(1, true).derive(i)
        addr = a.key.to_addr
        #addr = Bitcoin::Key.new(pubkey: pub_key, key_type: Bitcoin::Key::TYPES[:p2wpkh])
        puts "p2wpkh:#{a.key.to_wif}"# -> #{addr}"
      end
      
      
      #puts '!!!!!!!!!'

      ## Bitcoin::Key::TYPES
    
      #key = master_key.derive(84, true).derive(0, true).derive(0, true).derive(0).derive(0)
      #key.to_wif
    end

    def addresses
      
    end

    def get_last_tx(addr)
      Bitcoin.chain_params = :signet

      path = "https://mempool.space/signet/api/address/#{addr}/txs"
      response = HTTParty.get(path) 
      j = JSON.parse(response.body)
      last = j.kind_of?(Array) ? j.first : j
      last['txid']
    end

    def get_coins(master_key, key_count)
      Bitcoin.chain_params = :signet
      puts '@@@@@@@@@', master_key
      ext_pub = Bitcoin::ExtPubkey.from_base58(master_key) # master public key
      puts ext_pub.inspect
      puts "-----> #{ext_pub.pubkey}"
      total = 0
      (0..key_count).each do |idx|
        #pub_key = ext_pub.derive(0).derive(idx).pubkey
        pub_key = ext_pub.derive(idx).pubkey
        puts ext_pub.derive(idx).key.inspect
        wif = '' #ext_pub.derive(idx).key.to_wif
        k = Bitcoin::Key.new(pubkey: pub_key, key_type: Bitcoin::Key::TYPES[:p2wpkh])
        #puts "#{k.to_addr}"
    
        _total = get_transactions(k.to_addr)
        puts "#{k.to_addr} #{pub_key} - #{wif} - #{_total}\n"
        total += _total
        #puts ''
      end
      #puts "======", total
    end

    def get_transactions(addr)
      path = "https://mempool.space/signet/api/address/#{addr}/txs"
      response = HTTParty.get(path) 
      j = JSON.parse(response.body)
     
      pubkey = ''
      total = 0
      if j.kind_of?(Array)
        e = j.first
        vin_sum = e['vin'].filter {|q| q['prevout']['scriptpubkey_address'] == addr }.sum { |k| k['prevout']['value'] || 0 }.to_i
        vout_sum = e['vout'].filter { |k| k['scriptpubkey_address'] == addr }.sum { |k| k['value'] || 0 }.to_i
        pubkey = e['vout'].filter { |k| k['scriptpubkey_address'] == addr }.first['scriptpubkey'] 
        total += (vout_sum - vin_sum)
      else
        e = j
        vin_sum = e['vin'].filter {|q| q['prevout']['scriptpubkey_address'] == addr }.sum { |k| k['prevout']['value'] || 0 }.to_i
        vout_sum = e['vout'].filter { |k| k['scriptpubkey_address'] == addr }.sum { |k| k['value'] || 0 }.to_i
        total += (vout_sum - vin_sum)
      end
      puts "#{pubkey} -> #{addr} ->> total = #{total}"
      total
    end



    def transaction4 trin, wif = nil
      Bitcoin.chain_params = :signet
      w = Address.find_by_eid(trin.in_addr)
      wif = w.wif

      keyi = Bitcoin::Key.from_wif(wif)
      #priv_key = keyi.priv_key
      pub_key = keyi.pubkey
      addr = keyi.to_p2wpkh

      last_txid = get_last_tx(addr)
      last_sum = get_transactions(addr)
      puts "LAST_TXID = #{last_txid}, last-sum = #{last_sum}"

      tx = Bitcoin::Tx.new
      tx.in << Bitcoin::TxIn.new(out_point: Bitcoin::OutPoint.from_txid(last_txid, 0))
      puts "переводим - от транзакции = #{last_txid} - после которой на счету - #{last_sum}"

      w0 = (trin.in_value.to_i + trin.fee_value.to_i).to_i
      w_ = in_value = trin.in_value.to_i
      change = (w.balance.to_i - w0).to_i
      #change = (330969 - w0).to_i
      w1 = (trin.in_value.to_i + change).to_i
     
      fee = trin.fee_value.to_i
      amount = (trin.in_value.to_i + change).to_i
      puts "w0 = #{w0}, w1 = #{w1}, in_value = #{in_value}, fee = #{fee}"

      tx.out << Bitcoin::TxOut.new(value: trin.in_value.to_i, script_pubkey: Bitcoin::Script.parse_from_addr(trin.out_addr)) # адрес получения
      tx.out << Bitcoin::TxOut.new(value: change, script_pubkey: Bitcoin::Script.parse_from_addr(trin.change_addr)) # сдача

      
       puts "balance = #{w.balance}, change = #{change}, w0 - #{w0}, fee = #{trin.fee_value}, trin.in_value = #{trin.in_value.to_i}"

      tx.version = 2

      puts "amount = #{ (trin.in_value.to_i + change)}"

      input_index = 0
      script_input_pubkey = Bitcoin::Script.parse_from_addr(addr)
      sig_hash = tx.sighash_for_input(input_index, script_input_pubkey, sig_version: :witness_v0, amount: 50000)
      signature = keyi.sign(sig_hash) + [Bitcoin::SIGHASH_TYPE[:all]].pack('C')

      tx.in[0].script_witness.stack << signature
      tx.in[0].script_witness.stack << pub_key.htb
      verifed = tx.verify_input_sig(0, script_input_pubkey, amount: 50000)
      puts "verifed = #{verifed}"

      tx.to_hex

      puts "curl -X POST -sSLd \"#{tx.to_hex}\" \"https://mempool.space/signet/api/tx\""
    end

    #curl -X POST -sSLd "" "https://mempool.space/signet/api/tx"
  end

  #https://mempool.space/signet/api/address/tb1qkwsgh242w79wjrrv0mq0p8jw02ucn0epr8pxrm/txs

 # 020000000001014bfe1cc280dfad3993f6c90c854075ea220c29b7f266ceb04b85b965d25501520000000000ffffffff02d859000000000000160014e92cc42c783318d8e7cef076d11d243754bfc735a61800000000000016001473edac3128043d6905ed69a6e846e0a6b665a2f60247304402201fd9520dae48d16c01bbf06ed01efc83bff008d6cbfd1dcd21d860ddae64f6ef0220040927731cac87f37d987d6d5ce5dad9d436b1f57dde27ac3dfcb81fdf4709e6012102c02531f089f392a5df83248bd68b4c1f625e3ceaaefc9926aa19b9812edc80bd00000000
#curl -X POST -sSLd "020000000001014bfe1cc280dfad3993f6c90c854075ea220c29b7f266ceb04b85b965d25501520000000000ffffffff02882c0000000000001600146b14a101c5d5a95166ca427eaae0cea8d29b4b95d0070000000000001600147648933eeb2ed87d906907df88108b2ec19b607c02473044022062402169958b136384892e8e887c7fbfc906fbc376dac1f3ba1db8b6c9acba9e022022aafd0325bec10a1ac6a286341abecf05d94c3b0428dd42b44c1f87effb7414012102c02531f089f392a5df83248bd68b4c1f625e3ceaaefc9926aa19b9812edc80bd00000000" "https://mempool.space/signet/api/tx"
  
end