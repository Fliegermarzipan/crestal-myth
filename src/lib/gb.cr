require "./component/memory"
require "./component/cpu"

module Crestal::Myth
  class GB
    def initialize(@cartridge : Cartridge)
      @ram = Component::Memory.new
      @cpu = Component::CPU.new @ram

      load @cartridge
    end

    def load(@cartridge : Cartridge)
      Log.new.warn "Possibly unsupported cartridge type" if @cartridge.type != 0

      @cartridge.read_until(0x0000, 0x8000).each.with_index do |cdata, cindex|
        @ram.write cindex.to_u16, cdata
      end
    end

    def run
      loop do
        @cpu.ram.inc 0x44_u8
        @cpu.ram.write 0x44_u8, 0_u8 if @cpu.ram.read(0x44_u8) > 153
        break unless @cpu.step
      end
    end
  end
end
