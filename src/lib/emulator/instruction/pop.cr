require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class POP < Opcode
    def call(cpu) : Bool
      target = Component::Reg16::Placeholder

      case @args[0]
      when Component::Reg16
        target = @args[0].as(Component::Reg16)
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      cpu.reg.write target, cpu.ram.read16 cpu.reg.read Component::Reg16::SP
      cpu.reg.inc Component::Reg16::SP, 2

      true
    end
  end
end
