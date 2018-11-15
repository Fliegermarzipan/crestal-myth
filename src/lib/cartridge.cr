module Crestal::Myth
  class Cartridge
    @name = ""
    @code = ""
    @type = 0_u8
    @data = uninitialized Bytes

    def initialize(path)
      f = File.open path, "r"
      s = Bytes.new f.size
      f.read s
      @data = s

      @name = read_string 0x134, 0x13F
      @code = read_string 0x13F, 0x143
      @type = @data[0x147]
    end

    def read_string(start, stop)
      read_until(start, stop).map { |b| b.chr }.join("")
    end

    def read_until(start, stop)
      ret = [] of UInt8
      (stop - start).times do |t|
        ret << @data[start + t]
      end
      ret
    end

    def read(start, amount)
      read_until start, start + amount
    end

    def name
      return @name
    end

    def code
      return @code
    end

    def type
      return @type
    end
  end
end
