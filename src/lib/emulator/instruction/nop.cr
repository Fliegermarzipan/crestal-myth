require "../opcode"

module Crestal::Myth::Emulator::Instruction
  class NOP < Opcode
    def call(cpu) : Bool
      true
    end
  end
end
