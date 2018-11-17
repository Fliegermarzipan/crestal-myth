require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class EI < Opcode
    def call(cpu) : Bool
      cpu.set_ime

      true
    end
  end
end
