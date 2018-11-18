module Crestal::Myth::Component
  enum IRQType
    Placeholder = 0
    VBLANK      = 1
    LCDSTAT     = 1 << 1
    TIMER       = 1 << 2
    SERIAL      = 1 << 3
    JOYPAD      = 1 << 4
  end

  class IRQ
    @master_enable : Bool = true
    @queued : IRQType = IRQType::Placeholder

    def disable
      @master_enable = false
    end

    def enable
      @master_enable = true
    end

    def dispatch(cpu)
      if @queued != IRQType::Placeholder
        Log.new.debug "Dispatching #{@queued} interrupt"
        cpu.reg.write Component::Reg16::PC, self.addr @queued
        @queued = IRQType::Placeholder
      end
    end

    def send(irq : IRQType)
      Log.new.debug "Requested #{irq} interrupt"
      if @queued < irq
        @queued = irq
      end
    end

    def addr(irq : IRQType) : UInt16
      case irq
      when IRQType::VBLANK
        return 0x0040_u16
      when IRQType::LCDSTAT
        return 0x0048_u16
      when IRQType::TIMER
        return 0x0050_u16
      when IRQType::SERIAL
        return 0x0058_u16
      when IRQType::JOYPAD
        return 0x0060_u16
      else
        Log.new.fatal "Cannot resolve address of IRQ type #{irq}"
        return 0x0000_u16
      end
    end
  end
end
