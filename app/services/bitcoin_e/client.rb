require 'bitcoin'
require 'httparty'

module BitcoinE
  
  class Client
    attr_reader :master_key

    def initialize
      Bitcoin.chain_params = :signet
    end


    def self.generate
      Bitcoin.chain_params = :signet
      mnemonic = Bitcoin::Mnemonic.new('english')
      entropy = SecureRandom.hex(32)
      word_list = mnemonic.to_mnemonic(entropy)
      seed = mnemonic.to_seed(word_list)
      
      master_key = Bitcoin::ExtKey.generate_master(seed)
      wif = master_key.key.to_wif

      t = {
        master_key: master_key.derive(84, true).derive(0, true).ext_pubkey.to_base58,
        wif: wif,
        ext_pub: master_key.ext_pubkey.pubkey,
        words: word_list,
        in_addr: addr_generator(master_key, 0),
        out_addr: addr_generator(master_key, 1)
      }

      File.open("out_#{Time.now.to_i}.json", 'w') do |f|
        f.write(t.to_json)
      end
    end

    def self.addr_generator(master_key, idx, count = 10)
      (0..count).map do |i|
        a = master_key.derive(84, true).derive(idx, true).derive(i)
        addr = a.key.to_addr
        
        {
          addr: addr,
          wif: "p2wpkh:#{a.key.to_wif}"  
        }
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