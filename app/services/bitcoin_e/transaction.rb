module BitcoinE
  class Transaction
    def initialize tx
      @trin = tx
    end

    def call
      w = Address.find_by_eid(@trin.in_addr)
      wif = w.wif

      keyi = Bitcoin::Key.from_wif(wif)
      pub_key = keyi.pubkey

      last_txid = get_last_tx(@trin.in_addr)
      
      e = BitcoinE::Helpers.get_transactions_for_in(@trin.in_addr)
      last_sum = e.last
      tx = Bitcoin::Tx.new
      tx.in << Bitcoin::TxIn.new(out_point: Bitcoin::OutPoint.from_txid(last_txid, e.first))

      fee_value = @trin.fee_value.to_i
      in_value = @trin.in_value.to_i

      change_value = (last_sum - fee_value - in_value).to_i

      tx.out << Bitcoin::TxOut.new(value: in_value, script_pubkey: Bitcoin::Script.parse_from_addr(@trin.out_addr)) # адрес получения
      tx.out << Bitcoin::TxOut.new(value: change_value, script_pubkey: Bitcoin::Script.parse_from_addr(@trin.change_addr))

      tx.version = 2

      input_index = 0
      script_input_pubkey = Bitcoin::Script.parse_from_addr(@trin.in_addr)
      sig_hash = tx.sighash_for_input(input_index, script_input_pubkey, sig_version: :witness_v0, amount: last_sum)
      signature = keyi.sign(sig_hash) + [Bitcoin::SIGHASH_TYPE[:all]].pack('C')

      tx.in[0].script_witness.stack << signature
      tx.in[0].script_witness.stack << pub_key.htb
      verifed = tx.verify_input_sig(0, script_input_pubkey, amount: last_sum)
      raise 'Transaction not virifed' unless verifed

      tx.to_hex
    end
  end
end