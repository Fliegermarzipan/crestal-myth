require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class CP < Opcode
    def call(cpu) : Bool
      value = 0_u16

      case @args[0]
      when Component::Reg8
        value = cpu.reg.read @args[0].as(Component::Reg8)
      when Component::Reg16Mem
        value = cpu.reg.read(Component::Reg16.new(@args[0].as(Component::Reg16Mem).value))
      when DirectValue::BYTE
        value = cpu.ram.read cpu.reg.read Component::Reg16::PC
        cpu.reg.inc Component::Reg16::PC
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      a = cpu.reg.read Component::Reg8::A
      res = a - value

      cpu.reg.flag_write Component::Flag::Z, res == 0
      cpu.reg.flag_write Component::Flag::N, true
      cpu.reg.flag_write Component::Flag::H, (res & 0xF) == 0xF
      cpu.reg.flag_write Component::Flag::C, a < res

      true
    end
  end
end
