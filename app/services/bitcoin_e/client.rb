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

      e = @master_key.derive(84, true).derive(0, true).derive(0, true)
      q = e.key.to_wif

      t = {
        master_key: @master_key.to_s,
        wif: wif,
        #ext_pub: @master_key.ext_pubkey.pubkey,
        #base58: @master_key.to_base58,
        words: word_list
      }

      File.open('out.json', 'w') do |f|
        f.write(t.to_json)
      end

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

    def get_transactions_for_in(addr)
      path = "https://mempool.space/signet/api/address/#{addr}/txs"
      response = HTTParty.get(path) 
      j = JSON.parse(response.body)
     
      index = 0
      value = 0
      if j.kind_of?(Array)
        j.first['vout'].each_with_index do |e, i|
          if e['scriptpubkey_address'] == addr
            puts "#{i} == #{e}"
            value = e['value']
            index = i
          end
        end
      end
      [index, value]
    end

    def get_transactions3(addr)
      path = "https://mempool.space/signet/api/address/#{addr}/txs"
      response = HTTParty.get(path) 
      j = JSON.parse(response.body)
     
      pubkey = ''
      total = 0
      if j.kind_of?(Array)
        puts "size-of #{j.size}"
        e = j.first
        puts e['vout'].size
        vin_sum = e['vin'].filter {|q| q['prevout']['scriptpubkey_address'] == addr }.sum { |k| k['prevout']['value'] || 0 }.to_i
        vout_sum = e['vout'].filter { |k| k['scriptpubkey_address'] == addr }.sum { |k| k['value'] || 0 }.to_i

        e['vout'].each_with_index do |e, i|
          #puts e
          if e['scriptpubkey_address'] == addr
            puts "#{i} == #{e}"
          end
        end

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
      
      #tx.out << Bitcoin::TxOut.new(value: 288870, script_pubkey: Bitcoin::Script.parse_from_addr(trin.change_addr))
      
       puts "balance = #{w.balance}, change = #{change}, w0 - #{w0}, fee = #{trin.fee_value}, trin.in_value = #{trin.in_value.to_i}"

      tx.version = 2

      puts "amount = #{ (trin.in_value.to_i + change)}"

      input_index = 0
      script_input_pubkey = Bitcoin::Script.parse_from_addr(addr)
      sig_hash = tx.sighash_for_input(input_index, script_input_pubkey, sig_version: :witness_v0, amount: last_sum)
      signature = keyi.sign(sig_hash) + [Bitcoin::SIGHASH_TYPE[:all]].pack('C')

      tx.in[0].script_witness.stack << signature
      tx.in[0].script_witness.stack << pub_key.htb
      verifed = tx.verify_input_sig(0, script_input_pubkey, amount: last_sum)
      puts "verifed = #{verifed}"

      tx.to_hex

      puts "curl -X POST -sSLd \"#{tx.to_hex}\" \"https://mempool.space/signet/api/tx\""
    end


    def transaction5 trin
      Bitcoin.chain_params = :signet
      w = Address.find_by_eid(trin.in_addr)
      wif = w.wif

      keyi = Bitcoin::Key.from_wif(wif)
      pub_key = keyi.pubkey
      #addr = keyi.to_p2wpkh

      last_txid = get_last_tx(trin.in_addr)
      
      e = BitcoinE::Client.new.get_transactions_for_in(trin.in_addr)
      last_sum = e.last
      puts "last_txid = #{last_txid}, last_sum = #{last_sum}"
      tx = Bitcoin::Tx.new
      tx.in << Bitcoin::TxIn.new(out_point: Bitcoin::OutPoint.from_txid(last_txid, e.first))

      fee_value = trin.fee_value.to_i
      in_value = trin.in_value.to_i

      change_value = (last_sum - fee_value - in_value).to_i

      tx.out << Bitcoin::TxOut.new(value: in_value, script_pubkey: Bitcoin::Script.parse_from_addr(trin.out_addr)) # адрес получения
      tx.out << Bitcoin::TxOut.new(value: change_value, script_pubkey: Bitcoin::Script.parse_from_addr(trin.change_addr))

      tx.version = 2

      input_index = 0
      script_input_pubkey = Bitcoin::Script.parse_from_addr(trin.in_addr)
      sig_hash = tx.sighash_for_input(input_index, script_input_pubkey, sig_version: :witness_v0, amount: last_sum)
      signature = keyi.sign(sig_hash) + [Bitcoin::SIGHASH_TYPE[:all]].pack('C')

      tx.in[0].script_witness.stack << signature
      tx.in[0].script_witness.stack << pub_key.htb
      verifed = tx.verify_input_sig(0, script_input_pubkey, amount: last_sum)
      puts "verifed = #{verifed}"

      tx.to_hex

      puts "curl -X POST -sSLd \"#{tx.to_hex}\" \"https://mempool.space/signet/api/tx\""
    end

    #curl -X POST -sSLd "" "https://mempool.space/signet/api/tx"
  end

end