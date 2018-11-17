require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class CPL < Opcode
    def call(cpu) : Bool
      res = cpu.reg.read(Component::Reg8::A)
      res = ~res

      @args.each do |arg|
        case arg
        else
          Log.new.fatal "Unimplemented #{disasm cpu}"
          return false
        end
      end

      cpu.reg.write(Component::Reg8::A, res)
      cpu.reg.flag_write(Component::Flag::N, true)
      cpu.reg.flag_write(Component::Flag::H, true)

      true
    end
  end
end
