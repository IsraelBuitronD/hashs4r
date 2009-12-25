require File.join(File.dirname(__FILE__), 'md54r')

test_str = "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkm"

puts "Testing over MD5"
[16,64,256,1024,2048].each do |blocks|
  case_str = test_str*blocks

  puts "Blocks\t#{case_str.bytesize*8/512} of 512 bits"
  t0 = Time.now
  md5sum(case_str)
  t1 = Time.now
  puts "Done in #{t1-t0} segs"
end

puts ''
