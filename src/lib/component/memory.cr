module Crestal::Myth::Component
  class Memory
    @raw = Bytes.new(0x10000)

    def write(addr : UInt16, val : UInt8)
      @raw[addr] = val
    end

    def write(addr : UInt8, val : UInt8)
      write(0xFF00_u16 + addr, val)
    end

    def write16(addr : UInt16, val : UInt16)
      @raw[addr + 1] = (val >> 8).to_u8
      @raw[addr] = val.to_u8
    end

    def read(addr : UInt16) : UInt8
      @raw[addr]
    end

    def read(addr : UInt8) : UInt8
      read(0xFF00_u16 + addr)
    end

    def read16(addr : UInt16) : UInt16
      @raw[addr + 1].to_u16 << 8 | @raw[addr]
    end

    def dec(addr : UInt16, amount = 1)
      @raw[addr] -= amount
    end

    def inc(addr : UInt16, amount = 1)
      @raw[addr] += amount
    end

    def inc(addr : UInt8, amount = 1)
      inc(0xFF00_u16 + addr, amount)
    end

    def dec(addr : UInt8, amount = 1)
      dec(0xFF00_u16 + addr, amount)
    end
  end
end
