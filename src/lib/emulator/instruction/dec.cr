require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class DEC < Opcode
    def call(cpu) : Bool
      target_reg = true
      target = Component::Reg8::Placeholder

      case @args[0]
      when Component::Reg8, Component::Reg16
        target_reg = true
        target = @args[0].as(Component::Reg8 | Component::Reg16)
      when Component::Reg16Mem
        target_reg = false
        target = cpu.reg.read(Component::Reg16.new(@args[0].as(Component::Reg16Mem).value))
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      res = 0
      if target_reg
        cpu.reg.dec target.as(Component::Reg8 | Component::Reg16)
        res = cpu.reg.read target.as(Component::Reg8 | Component::Reg16)
      else
        cpu.ram.dec target.as(UInt16)
        res = cpu.ram.read target.as(UInt16)
      end

      cpu.reg.flag_write Component::Flag::Z, res == 0
      cpu.reg.flag_write Component::Flag::N, true
      cpu.reg.flag_write Component::Flag::H, (res & 0xF) == 0xF

      true
    end
  end
end
