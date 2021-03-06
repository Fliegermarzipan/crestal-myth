module Crestal::Myth::Component
  enum Reg8
    A
    F
    B
    C
    D
    E
    H
    L
    Placeholder
  end

  enum Reg8Mem
    A
    F
    B
    C
    D
    E
    H
    L
  end

  enum Reg16
    AF
    BC
    DE
    HL
    SP
    PC
    Placeholder
  end

  enum Reg16Mem
    BC
    DE
    HL
  end

  enum Flag
    C = 4
    H = 5
    N = 6
    Z = 7
  end

  class CPURegs
    @reg = StaticArray(UInt8, 8).new 0
    @sp = 0_u16
    @pc = 0_u16

    def flag_read(f : Flag) : Bool
      @reg[Reg8::F.value].bit(f.value) == 1
    end

    def flag_write(f : Flag, b : Bool)
      mask = 1 << f.value
      if b
        write Reg8::F, read(Reg8::F) | mask
      else
        write Reg8::F, read(Reg8::F) & ~mask
      end
    end

    def write(reg : Reg8, value : UInt8)
      @reg[reg.value] = value.as(UInt8)
    end

    def write(reg : Reg16, value : UInt16)
      case reg
      when Reg16::PC
        return @pc = value
      when Reg16::SP
        return @sp = value
      else
        @reg[reg.value * 2] = (value >> 8).to_u8
        @reg[reg.value * 2 + 1] = value.to_u8
      end
    end

    def read(reg : Reg8) : UInt8
      @reg[reg.value]
    end

    def read(reg : Reg16) : UInt16
      case reg
      when Reg16::PC
        return @pc
      when Reg16::SP
        return @sp
      else
        return @reg[reg.value * 2].to_u16 << 8 | @reg[reg.value * 2 + 1]
      end
    end

    def inc(reg : Reg8, amount = 1)
      @reg[reg.value] += amount
    end

    def inc(reg : Reg16, amount = 1)
      case reg
      when Reg16::PC
        return @pc += amount
      when Reg16::SP
        return @sp += amount
      else
        res = (@reg[reg.value * 2].to_u16 << 8 | @reg[reg.value * 2 + 1]) + amount
        @reg[reg.value * 2] = (res >> 8).to_u8
        @reg[reg.value * 2 + 1] = res.to_u8
      end
    end

    def dec(reg : Reg8, amount = 1)
      @reg[reg.value] -= amount
    end

    def dec(reg : Reg16, amount = 1)
      case reg
      when Reg16::PC
        return @pc -= amount
      when Reg16::SP
        return @sp -= amount
      else
        res = (@reg[reg.value * 2].to_u16 << 8 | @reg[reg.value * 2 + 1]) - amount
        @reg[reg.value * 2] = (res >> 8).to_u8
        @reg[reg.value * 2 + 1] = res.to_u8
      end
    end
  end
end
