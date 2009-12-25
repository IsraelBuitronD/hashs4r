#! /usr/bin/ruby

class Integer
  def neg(bits_length=32)
    ~self & (2**bits_length -1)
  end
  
  def leftrotate(bits_rotate, bits_length = 32) 
    (((self << bits_rotate) | (self >> (bits_length-bits_rotate))) & (2**bits_length -1))
  end
  
  def to_s2(str='')
    "#{str} =>\t#{self}\t#{self.to_s(16)}\t#{self.to_s(2)}\t#{self>(2**32)?'>32':''}"
  end
end


def md5sum(message)
  # r specifies the per-round shift amounts
  r = [7, 12, 17, 22,  7, 12, 17, 22,  
       7, 12, 17, 22,  7, 12, 17, 22,
       5,  9, 14, 20,  5,  9, 14, 20,  
       5,  9, 14, 20,  5,  9, 14, 20,
       4, 11, 16, 23,  4, 11, 16, 23,  
       4, 11, 16, 23,  4, 11, 16, 23,
       6, 10, 15, 21,  6, 10, 15, 21,  
       6, 10, 15, 21,  6, 10, 15, 21 ]
  
  # Use binary integer part of the sines of integers (Radians) as
  # constants:
  k = []
  (0..63).each { |i| k << ((Math.sin(i+1) * (2**32) ).abs).floor }
  
  # Initialize variables:
  h0 = 0x67452301
  h1 = 0xEFCDAB89
  h2 = 0x98BADCFE
  h3 = 0x10325476

  # Getting bits message
  message_bytes = message.bytes.to_a
  message_bits = []
  message_bytes.each do |byte|
    7.downto(0) do |bit|
      message_bits << ((byte & (1 << bit)) >> bit)
    end
  end
  
  unpadded_msg_len = message_bits.length
  
  # Append "1" bit to message
  message_bits << 1
  
  # Append "0" bits until message length in bits = 448 (mod 512)
  message_bits << 0 until message_bits.length % 512 == 448
  
  # Append bit (not byte) length of unpadded message as 64-bit
  # little-endian integer to message
  63.downto(0) do |bit|
    message_bits << ((unpadded_msg_len & (1 << bit)) >> bit)
  end

  n=message_bits.length / 512
  
  # Process the message in successive 512-bit chunks
  (0...n).each do |j|
    
    # Break chunk into sixteen 32-bit little-endian 
    # words w[i], i in 0..15
    chunk = message_bits[(512*j),512]
    w = []
    (0...16).each { |i| w << chunk[(16*i),16].join.to_i(2) }
    
    # Initialize hash value for this chunk:
    a, b, c, d = h0, h1, h2, h3
    
    # Main loop
    (0..63).each do |i|
      case i
      when 0..15 then
        f = (b & c) | (b.neg & d)
        g = i
      when 16..31 then
        f = (d & b) | (d.neg & c)
        g = (5*i + 1) % 16
      when 32..47 then
        f = b ^ c ^ d
        g = (3*i + 5) % 16
      when 48..63 then
        f = c ^ (b | d.neg)
        g = (7*i) % 16
      end

      temp = d
      d = c
      c = b
      b = (b + (a + f + k[i] + w[g]).leftrotate(r[i],32)) #& 0xFFFFFFFF
      a = temp
    end

    # Add this chunk's hash to result so far:

    h0 = h0 + a
    h1 = h1 + b 
    h2 = h2 + c
    h3 = h3 + d
    
  end
  
  hash = ((h0 << 96) | (h1 << 64) | (h2 << 32) | h3) & (2**128 -1)
  
  return hash.to_s(16)

end
