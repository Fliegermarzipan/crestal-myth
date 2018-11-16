require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class NOP < Opcode
    def asminstr
      "NOP"
    end

    def call(cpu) : Bool
      true
    end
  end
end
