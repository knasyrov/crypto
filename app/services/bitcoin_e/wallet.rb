module BitcoinE
  class Wallet
    def initialize
      
    end

    def call
      return if File.exist?('wallet.json')


      
      word_list = BitcoinE::Helpers.generate_word_list
      seed = BitcoinE::Helpers.generate_seed(word_list)
      
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

    protected

    def addr_generator(master_key, idx, count = 10)
      (0...count).map do |i|
        a = master_key.derive(84, true).derive(0, true).derive(0, true).derive(idx).derive(i)
        addr = a.key.to_addr
        {
          addr: addr,
          wif: "p2wpkh:#{a.key.to_wif}"  
        }
      end
    end
  end
end