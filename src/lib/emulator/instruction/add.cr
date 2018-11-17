require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class ADD < Opcode
    def call(cpu) : Bool
      target_reg = true
      target_8 = true
      target = Component::Reg8::Placeholder

      case @args[0]
      when Component::Reg8
        target_reg = true
        target = @args[0].as(Component::Reg8)
      when Component::Reg16
        target_reg = true
        target_8 = false
        target = @args[0].as(Component::Reg16)
      when Component::Reg16Mem
        target_reg = false
        target = cpu.reg.read(Component::Reg16.new(@args[0].as(Component::Reg16Mem).value))
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      value = 0_u8
      case @args[1]
      when Component::Reg8, Component::Reg16
        value = cpu.reg.read @args[0].as(Component::Reg8 | Component::Reg16)
      when Component::Reg16Mem
        value = cpu.ram.read cpu.reg.read Component::Reg16.new(@args[0].as(Component::Reg16Mem).value)
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
      end

      res = 0
      orig = 0
      if target_reg
        orig = cpu.reg.read(target.as(Component::Reg8 | Component::Reg16))
        res = orig + value
        if target_8
          cpu.reg.write target.as(Component::Reg8), res.to_u8
        else
          cpu.reg.write target.as(Component::Reg16), res.to_u16
        end
      else
        orig = cpu.ram.read(target.as(UInt16))
        res = orig + value
        cpu.ram.write target.as(UInt16), res.to_u8
      end

      cpu.reg.flag_write Component::Flag::Z, res == 0
      cpu.reg.flag_write Component::Flag::N, false
      if target_8
        cpu.reg.flag_write Component::Flag::H, (res & 0xff) < (orig & 0xff)
        cpu.reg.flag_write Component::Flag::C, res > 0xff
      else
        cpu.reg.flag_write Component::Flag::H, (res & 0xfff) < (orig & 0xfff)
        cpu.reg.flag_write Component::Flag::C, res > 0xffff
      end

      true
    end
  end
end
