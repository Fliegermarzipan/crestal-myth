module Crestal::Myth::Component
  class Memory
    @raw = Bytes.new(0xFFFF)

    def write(addr : UInt16, val : UInt8)
      @raw[addr] = val
    end

    def write(addr : UInt8)
      write(addr + 0xFF00)
    end

    def write16(addr : UInt16, val : UInt16)
      @raw[addr] = val >> 8
      @raw[addr + 1] = val
    end

    def read(addr : UInt16) : UInt8
      @raw[addr]
    end

    def read(addr : UInt8) : UInt8
      read(addr + 0xFF00)
    end

    def read16(addr : UInt16) : UInt16
      @raw[addr].to_u16 << 8 | @raw[addr + 1]
    end
  end
end
