require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class SWAP < Opcode
    def call(cpu) : Bool
      is_reg = true
      target = Component::Reg8::Placeholder

      case @args[0]
      when Component::Reg8
        is_reg = true
        target = @args[0].as(Component::Reg8)
      when Component::Reg16Mem
        is_reg = false
        target = cpu.reg.read(Component::Reg16.new(@args[0].as(Component::Reg16Mem).value))
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      res = 0_u8

      if is_reg
        res = cpu.reg.read(target.as(Component::Reg8))
        res == res << 4 | res >> 4
        cpu.reg.write(target.as(Component::Reg8), res)
      else
        res = cpu.ram.read(target.as(UInt16))
        res == res << 4 | res >> 4
        cpu.ram.write(target.as(UInt16), res)
      end

      cpu.reg.flag_write Component::Flag::Z, res == 0
      cpu.reg.flag_write Component::Flag::N, false
      cpu.reg.flag_write Component::Flag::H, false
      cpu.reg.flag_write Component::Flag::C, false

      true
    end
  end
end
