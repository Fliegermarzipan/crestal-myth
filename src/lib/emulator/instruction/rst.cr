require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class RST < Opcode
    def call(cpu) : Bool
      cond = true
      jmp = 0x0000_u16

      case @args[0]
      when UInt8
        jmp = @args[0].to_u16
      else
        Log.new.fatal "Unimplemented #{disasm cpu}"
        return false
      end

      cpu.reg.write Component::Reg16::PC, jmp if cond
      true
    end
  end
end
