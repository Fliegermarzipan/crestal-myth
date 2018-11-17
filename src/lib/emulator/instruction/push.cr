require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class PUSH < Opcode
    def call(cpu) : Bool
      value = 0x0000_u16

      case @args[0]
      when Component::Reg16
        value = cpu.reg.read @args[0].as(Component::Reg16)
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      cpu.reg.dec Component::Reg16::SP, 2
      cpu.ram.write16 cpu.reg.read(Component::Reg16::SP), value

      true
    end
  end
end
