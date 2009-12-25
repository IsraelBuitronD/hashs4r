require "whirlpool4r"
require "test/unit"
 
class TestWhirlpool4R < Test::Unit::TestCase
  
  def test_benchmark
    w = Whirlpool.new
    digest = Array.new(512)
    test_str = "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkm"

    puts "Testing over Whirlpool"

    [16,64,256,1024,2048,8094].each do |blocks|
      case_str = test_str*blocks

      puts "Blocks\t#{case_str.bytesize*8/512} of 512 bits"
      t0 = Time.now
      w.nessie_init
      w.nessie_add_str(case_str)
      w.nessie_finalize(digest)
      t1 = Time.now
      puts "Done in #{t1-t0} seg"
    end
  end
  
  def test_iso_test_vectors
    w = Whirlpool.new
    digest = Array.new(512)

    w.nessie_init
    w.nessie_finalize(digest)
    assert_equal('19FA61D75522A4669B44E39C1D2E1726C530232130D407F89AFEE0964997F7A73E83BE698B288FEBCF88E3E03C4F0757EA8964E59B63D93708B138CC42A66EB3', 
                 Whirlpool.display(digest) )

    w.nessie_init
    w.nessie_add_str('a')
    w.nessie_finalize(digest)
    assert_equal('8ACA2602792AEC6F11A67206531FB7D7F0DFF59413145E6973C45001D0087B42D11BC645413AEFF63A42391A39145A591A92200D560195E53B478584FDAE231A', 
                 Whirlpool.display(digest) )

    w.nessie_init
    w.nessie_add_str('abc')
    w.nessie_finalize(digest)
    assert_equal('CF829AADB53F43809B7BF53ACF6F93F2403BCECC0450920A1FA86ADFD5F3F10F332B7C4A340CCE78A0A502AAE6B8BCA89D454ABB8B175B03478E71C6A9BA20AC', 
                 Whirlpool.display(digest) )

    w.nessie_init
    w.nessie_add_str('message digest')
    w.nessie_finalize(digest)
    assert_equal('A15C8C0AAB1CEC46CF98AD75EE4F700E1685BA615B35A8D726FFD9279DEC8B0E5B957BA2EE1AD93EB5A8B58DA2A329C225BECF401ACE8AA1D91B38E54E2C35A7', 
                 Whirlpool.display(digest) )

    w.nessie_init
    w.nessie_add_str('abcdefghijklmnopqrstuvwxyz')
    w.nessie_finalize(digest)
    assert_equal('E9ED9C7C06F2F1C483A729D2CA546FDB9668537C02D6B11D45240C50FF9566CF66AEC0AB04334C103C9E216F1C9CFCB579A9BC212063361606244FDAB34799D4', 
                 Whirlpool.display(digest) )

    w.nessie_init
    w.nessie_add_str('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789')
    w.nessie_finalize(digest)
    assert_equal('797A542DF7A02BCF7BFEBB44D4179EB9D1A0CEA7414307329DD246E6565D8266685547393AE6D29789F599462DD88B49AEAC2E6448E028BB07E797D3DFC490DF', 
                 Whirlpool.display(digest) )

  end
 
end
