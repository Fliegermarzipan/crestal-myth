require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class DI < Opcode
    def call(cpu) : Bool
      cpu.reset_ime

      true
    end
  end
end
