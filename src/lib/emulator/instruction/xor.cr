require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class XOR < Opcode
    def asminstr
      "XOR"
    end

    def call(cpu) : Bool
      res = cpu.reg.read(Component::Reg8::A)

      @args.each do |arg|
        case arg
        when Component::Reg8
          res ^= cpu.reg.read arg
        when DirectValue::BYTE
          res ^= cpu.ram.read cpu.reg.read Component::Reg16::PC
          cpu.reg.inc Component::Reg16::PC
        when Component::Reg16Mem::HL
          res ^= cpu.ram.read cpu.reg.read Component::Reg16::HL
        else
          Log.new.fatal "Unimplemented #{disasm cpu}"
        end
      end

      cpu.reg.write(Component::Reg8::A, res)
      cpu.reg.flag_write(Component::Flag::Z, res == 0)
      cpu.reg.flag_write(Component::Flag::N, false)
      cpu.reg.flag_write(Component::Flag::H, false)
      cpu.reg.flag_write(Component::Flag::C, false)
      true
    end
  end
end
