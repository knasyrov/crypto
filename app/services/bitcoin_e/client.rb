require 'bitcoin'
require 'httparty'

module BitcoinE
  
  class Client

    class << self

      def generate
        return if File.exist?('wallet.json')

        Bitcoin.chain_params = :signet
        mnemonic = Bitcoin::Mnemonic.new('english')
        entropy = SecureRandom.hex(32)
        word_list = mnemonic.to_mnemonic(entropy)
        seed = mnemonic.to_seed(word_list)
        
        master_key = Bitcoin::ExtKey.generate_master(seed)
        wif = master_key.key.to_wif

        data = {
          master_key: master_key.derive(84, true).derive(0, true).derive(0, true).ext_pubkey.to_base58,
          wif: wif,
          ext_pub: master_key.ext_pubkey.pubkey,
          words: word_list,
          in_addr: addr_generator(master_key, 0),
          out_addr: addr_generator(master_key, 1)
        }

        File.open("wallet.json", 'w') do |f|
          f.write(data.to_json)
        end
      end

      def addr_generator(master_key, idx, count = 10)
        Bitcoin.chain_params = :signet

        (0...count).map do |i|
          a = master_key.derive(84, true).derive(0, true).derive(0, true).derive(idx).derive(i)
          addr = a.key.to_addr
          {
            addr: addr,
            wif: "p2wpkh:#{a.key.to_wif}"  
          }
        end
      end

      def load_data
        Bitcoin.chain_params = :signet

        file = File.open "wallet.json"
        data = JSON.load file
        master_key = Bitcoin::ExtPubkey.from_base58(data['master_key'])
        
        load_by_direction(master_key, data['in_addr'], 0)
        load_by_direction(master_key, data['out_addr'], 1)
      end

      def load_by_direction(master_key, data, direction) 
        data.each_with_index do |e, i|
          key = master_key.derive(direction).derive(i)
          path = "m/84/0'/0'/#{direction}/#{i}"
          
          addr = Address.new(
            eid: key.addr,
            path: path,
            direction: direction,
            wif: e['wif'].split(':').last
          )
          #addr.balance = get_balance(key.addr)
          addr.save
          putc '.'
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

=begin
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
=end

      def get_transactions_for_in(addr)
        path = "https://mempool.space/signet/api/address/#{addr}/txs"
        response = HTTParty.get(path) 
        j = JSON.parse(response.body)
      
        index = 0
        value = 0
        if j.kind_of?(Array) && !j.first.nil?
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


      def update_balance
        Address.all.each do |e|
          txs = get_transactions_for_in(e.eid)
          e.balance = txs.last
          e.save
        end
      end


      def transaction trin
        Bitcoin.chain_params = :signet
        w = Address.find_by_eid(trin.in_addr)
        wif = w.wif

        keyi = Bitcoin::Key.from_wif(wif)
        pub_key = keyi.pubkey

        last_txid = get_last_tx(trin.in_addr)
        
        e = BitcoinE::Client.get_transactions_for_in(trin.in_addr)
        last_sum = e.last
        #puts "last_txid = #{last_txid}, last_sum = #{last_sum}"
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
        #puts "verifed = #{verifed}"

        puts "curl -X POST -sSLd \"#{tx.to_hex}\" \"https://mempool.space/signet/api/tx\""

        tx.to_hex
      end
    end

  end
end