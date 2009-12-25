class Integer

  def neg(bits_length=32)
    ~self & (2**bits_length -1)
  end
  
  def leftrotate(bits_rotate, bits_length = 32) 
    (((self << bits_rotate) | (self >> (bits_length-bits_rotate))) & (2**bits_length -1))
  end
 
  def circular_left_shift(shift, word=32)
    return self if shift==0
    ((self >> shift) | (self << (word-shift))) & (2**word -1)
  end

end

class Whirlpool

  # The message digest size (in bits)
  @@DIGESTBITS = 512.freeze

  # The message digest size (in bytes)
  @@DIGESTBYTES = (@@DIGESTBITS >> 3).freeze

  # The number of rounds of the internal dedicated block cipher.
  @@R = 10.freeze

  # The substitution box.
  @@sbox = 
    [0x18, 0x23, 0xc6, 0xE8, 0x87, 0xB8, 0x01, 0x4F, 0x36, 0xA6, 0xd2, 0xF5, 0x79, 0x6F, 0x91, 0x52,
     0x60, 0xBc, 0x9B, 0x8E, 0xA3, 0x0c, 0x7B, 0x35, 0x1d, 0xE0, 0xd7, 0xc2, 0x2E, 0x4B, 0xFE, 0x57,
     0x15, 0x77, 0x37, 0xE5, 0x9F, 0xF0, 0x4A, 0xdA, 0x58, 0xc9, 0x29, 0x0A, 0xB1, 0xA0, 0x6B, 0x85,
     0xBd, 0x5d, 0x10, 0xF4, 0xcB, 0x3E, 0x05, 0x67, 0xE4, 0x27, 0x41, 0x8B, 0xA7, 0x7d, 0x95, 0xd8,
     0xFB, 0xEE, 0x7c, 0x66, 0xdd, 0x17, 0x47, 0x9E, 0xcA, 0x2d, 0xBF, 0x07, 0xAd, 0x5A, 0x83, 0x33,
     0x63, 0x02, 0xAA, 0x71, 0xc8, 0x19, 0x49, 0xd9, 0xF2, 0xE3, 0x5B, 0x88, 0x9A, 0x26, 0x32, 0xB0,
     0xE9, 0x0F, 0xd5, 0x80, 0xBE, 0xcd, 0x34, 0x48, 0xFF, 0x7A, 0x90, 0x5F, 0x20, 0x68, 0x1A, 0xAE,
     0xB4, 0x54, 0x93, 0x22, 0x64, 0xF1, 0x73, 0x12, 0x40, 0x08, 0xc3, 0xEc, 0xdB, 0xA1, 0x8d, 0x3d,
     0x97, 0x00, 0xcF, 0x2B, 0x76, 0x82, 0xd6, 0x1B, 0xB5, 0xAF, 0x6A, 0x50, 0x45, 0xF3, 0x30, 0xEF,
     0x3F, 0x55, 0xA2, 0xEA, 0x65, 0xBA, 0x2F, 0xc0, 0xdE, 0x1c, 0xFd, 0x4d, 0x92, 0x75, 0x06, 0x8A,
     0xB2, 0xE6, 0x0E, 0x1F, 0x62, 0xd4, 0xA8, 0x96, 0xF9, 0xc5, 0x25, 0x59, 0x84, 0x72, 0x39, 0x4c,
     0x5E, 0x78, 0x38, 0x8c, 0xd1, 0xA5, 0xE2, 0x61, 0xB3, 0x21, 0x9c, 0x1E, 0x43, 0xc7, 0xFc, 0x04,
     0x51, 0x99, 0x6d, 0x0d, 0xFA, 0xdF, 0x7E, 0x24, 0x3B, 0xAB, 0xcE, 0x11, 0x8F, 0x4E, 0xB7, 0xEB,
     0x3c, 0x81, 0x94, 0xF7, 0xB9, 0x13, 0x2c, 0xd3, 0xE7, 0x6E, 0xc4, 0x03, 0x56, 0x44, 0x7F, 0xA9,
     0x2A, 0xBB, 0xc1, 0x53, 0xdc, 0x0B, 0x9d, 0x6c, 0x31, 0x74, 0xF6, 0x46, 0xAc, 0x89, 0x14, 0xE1,
     0x16, 0x3A, 0x69, 0x09, 0x70, 0xB6, 0xd0, 0xEd, 0xcc, 0x42, 0x98, 0xA4, 0x28, 0x5c, 0xF8, 0x86 ].freeze
  
  @@C = []
  8.times { |i| @@C << Array.new(256,0) }
  @@rc = Array.new(@@R+1,0)
  
  (0...256).each do |x|
    index = (x/2).floor * 2
    c = ((@@sbox[index] << 8) | @@sbox[index+1])
    v1 = ((x & 1) == 0) ? c>>8 : (c&0xff)
    v2 = (v2 = v1 << 1) >= 0x100 ? v2 ^= 0x11d : v2
    v4 = (v4 = v2 << 1) >= 0x100 ? v4 ^= 0x11d : v4
    v5 = v4 ^ v1
    v8 = (v8 = v4 << 1) >= 0x100 ? v8 ^= 0x11d : v8
    v9 = v8 ^ v1

    @@C[0][x] = (
                 (v1 << 56) | 
                 (v1 << 48) | 
                 (v4 << 40) | 
                 (v1 << 32) |
                 (v8 << 24) | 
                 (v5 << 16) | 
                 (v2 <<  8) | 
                 (v9      ) )
    
    (1...8).each do |t|
      @@C[t][x] = (@@C[t-1][x]).circular_left_shift(8,64)
    end
  end

  # build the round constants:
  @@rc[0] = 0 # not used (assigment kept only to properly initialize all variables)
  
  (1..@@R).each do |r|
    i = 8*(r-1)
    @@rc[r] =
      (@@C[0][i  ] & 0xFF00000000000000) ^
      (@@C[1][i+1] & 0x00FF000000000000) ^
      (@@C[2][i+2] & 0x0000FF0000000000) ^
      (@@C[3][i+3] & 0x000000FF00000000) ^
      (@@C[4][i+4] & 0x00000000FF000000) ^
      (@@C[5][i+5] & 0x0000000000FF0000) ^
      (@@C[6][i+6] & 0x000000000000FF00) ^
      (@@C[7][i+7] & 0x00000000000000FF)
  end
  
  # Global number of hashed bits (256-bit counter).
  @bitLength = Array.new(32,0)

  # Buffer of data to hash.
  @buffer = Array.new(64,0)

  # Current number of bits on the buffer.
  @bufferBits = 0

  # Current (possibly incomplete) byte slot on the buffer.
  @bufferPos = 0

  public
  
  # The core Whirlpool transform.
  def process_buffer
    # map the buffer to a block:
    j=0
    (0...8).each do |i|
      @block[i] =
        ((@buffer[j  ]       ) << 56) ^
        ((@buffer[j+1] & 0xFF) << 48) ^
        ((@buffer[j+2] & 0xFF) << 40) ^
        ((@buffer[j+3] & 0xFF) << 32) ^
        ((@buffer[j+4] & 0xFF) << 24) ^
        ((@buffer[j+5] & 0xFF) << 16) ^
        ((@buffer[j+6] & 0xFF) <<  8) ^
        ((@buffer[j+7] & 0xFF)      )
      @block[i] &= (2**64-1)
      j += 8
    end

    (0...8).each { |i| @state[i] = @block[i] ^ (@K[i]=@hash[i]) }

    (1..@@R).each do |r|
      (0...8).each do |i|
        @L[i] = 0
        s = 56
        (0...8).each do |t|
          @L[i] ^= @@C[t][(@K[(i-t)&7] >> s) & 0xff]
          s -= 8
        end
      end
      
      (0...8).each { |i| @K[i] = @L[i] }
      @K[0] ^= @@rc[r]

      (0...8).each do |i|
        @L[i] = @K[i]
        s = 56
        (0...8).each do |t|
          @L[i] ^= @@C[t][(@state[(i-t)&7] >> s) & 0xff]
          s -= 8
        end
      end

      (0...8).each { |i| @state[i] = @L[i] }
    end

    # apply the Miyaguchi-Preneel compression function:
    (0...8).each { |i| @hash[i] ^= @state[i] ^ @block[i] }
  end
  
  def nessie_init()
    @bufferPos, @bufferBits = 0, 0
    @buffer    = Array.new(64,0)
    @bitLength = Array.new(32,0)

    # The hashing state.
    @hash  = Array.new(8,0)
    @K     = Array.new(8,0) # the round key
    @L     = Array.new(8,0)
    @block = Array.new(8,0) # mu(buffer)
    @state = Array.new(8,0) # the cipher state
  end
  
  def nessie_add_bytes(source, sourceBits)
    sourcePos = 0
    sourceGap = (8 - (sourceBits & 7)) & 7
    bufferRem = @bufferBits & 7
    
    # tally the length of the added data:
    value = sourceBits
    carry = 0

    31.downto(0) do |i|
      carry += (@bitLength[i] & 0xff) + (value & 0xff)
      @bitLength[i] = 0xFF & carry
      carry = carry >> 8
      value = value >> 8
    end
    
    # process data in chunks of 8 bits:
    while sourceBits > 8 
      # at least source[sourcePos] and source[sourcePos+1] contain
      # data.
      b = ((source[sourcePos] << sourceGap) & 0xff) | 
        ((source[sourcePos+1] & 0xff) >> (8-sourceGap))
      
      raise RuntimeError, 'Logic error' if b<0 or b>255
      
      # process this byte:
      @bufferPos += 1
      @buffer[@bufferPos] |= (b >> bufferRem)
      @bufferBits += (8 - bufferRem)

      if @bufferBits == 512
        process_buffer()
        # reset buffer:
        @bufferBits, @bufferPos = 0, 0
      end
      
      @buffer[@bufferPos] = (b << (8 - bufferRem)) & 0xff;
      @bufferBits += bufferRem;
      
      # proceed to remaining data:
      sourceBits -= 8
      sourcePos += 1

    end
    
    # now 0 <= sourceBits <= 8;
    if sourceBits > 0
      b = (source[sourcePos] << sourceGap) & 0xff
      @buffer[@bufferPos] |= (b >> bufferRem)
    else
      b = 0
    end

    if bufferRem + sourceBits < 8
      @bufferBits += sourceBits
    else
      @bufferPos += 1
      @bufferBits += 8 - bufferRem
      sourceBits -= 8 - bufferRem

      # now 0 <= sourceBits < 8; furthermore, all data is in
      # source[sourcePos].
      if @bufferBits == 512
        process_buffer()
        @bufferBits, @bufferPos = 0, 0
      end
         
      @buffer[@bufferPos] = (b << (8 - bufferRem)) & 0xff
      @bufferBits += sourceBits
    end

  end
  
  # Delivers string input data to the hashing algorithm.
  # str is a plaintext data to hash (ASCII text string).
  # This method maintains the invariant: bufferBits < 512
  def nessie_add_str(str)
    if str.length() > 0
      data = []
      str.each_byte { |i| data << (0xFF & i) }
      nessie_add_bytes(data, 8*data.size)      
    end
  end
  
  # Get the hash value from the hashing state.
  # This method uses the invariant: bufferBits < 512
  def nessie_finalize(digest)
    # append a '1'-bit:
    @buffer[@bufferPos] |= -0x80 >> (@bufferBits & 7)
    
    # all remaining bits on the current byte are set to zero.
    @bufferPos+=1
    # pad with zero bits to complete 512N + 256 bits:
    if @bufferPos > 32
      @buffer[@bufferPos+=1] = 0 while @bufferPos < 64
      process_buffer()
      @bufferPos = 0
    end
    
    @buffer[@bufferPos+=1] = 0 while @bufferPos < 32
     
    # append bit length of hashed data:
    @buffer[32,32] = @bitLength[0,32]
    
    # process data block:
    process_buffer()

    # return the completed message digest:
    j=0
    (0...8).each do |i|
      h = @hash[i]
      digest[j  ] = 0xFF & (h >> 56)
      digest[j+1] = 0xFF & (h >> 48)
      digest[j+2] = 0xFF & (h >> 40)
      digest[j+3] = 0xFF & (h >> 32)
      digest[j+4] = 0xFF & (h >> 24)
      digest[j+5] = 0xFF & (h >> 16)
      digest[j+6] = 0xFF & (h >>  8)
      digest[j+7] = 0xFF & (h      )
      j += 8
    end
  end

  def self.display(array, base=16)
    array.map{ |i| i.to_s(base) }.join()
  end
  
  # Generate the ISO/IEC 10118-3 test vector set for Whirlpool.
  def self.makeISOTestVectors
    w = Whirlpool.new
    digest = Array.new(@@DIGESTBYTES)
    data = Array.new(1000000,0)

    puts "1. In this example the data-string is the empty string, i.e. the string of length zero."
    w.nessie_init
    w.nessie_finalize(digest)
    puts Whirlpool.display(digest)

    puts "2. In this example the data-string consists of a single byte, namely the ASCII-coded version of the letter 'a'."
    w.nessie_init
    w.nessie_add_str("a")
    w.nessie_finalize(digest)
    puts Whirlpool.display(digest)

    puts "3. In this example the data-string is the three-byte string consisting of the ASCII-coded version of 'abc'."
    w.nessie_init
    w.nessie_add_str("abc")
    w.nessie_finalize(digest)
    puts Whirlpool.display(digest)

    puts "4. In this example the data-string is the 14-byte string consisting of the ASCII-coded version of 'message digest'."
    w.nessie_init
    w.nessie_add_str("message digest")
    w.nessie_finalize(digest)
    puts Whirlpool.display(digest)

    puts "8. In this example the data-string is the 32-byte string consisting of the ASCII-coded version of 'abcdbcdecdefdefgefghfghighijhijk'."
    w.nessie_init
    w.nessie_add_str("abcdbcdecdefdefgefghfghighijhijk")
    w.nessie_finalize(digest)
    puts Whirlpool.display(digest)

  end
  
end
