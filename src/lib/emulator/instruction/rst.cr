require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class RST < Opcode
    def call(cpu) : Bool
      jmp = 0x0000_u16

      case @args[0]
      when UInt8
        jmp = @args[0].to_u16
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      cpu.reg.dec Component::Reg16::SP, 2
      cpu.ram.write16 cpu.reg.read(Component::Reg16::SP), cpu.reg.read(Component::Reg16::PC)

      cpu.reg.write Component::Reg16::PC, jmp
      true
    end
  end
end
