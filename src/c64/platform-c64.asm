//-----------------------------------------------------------------------------
// Commodore 64 platform constants.
//
// All C64-specific addresses and magic values live here, keeping macros.asm
// machine-agnostic (design decision D-7).
//
// The main (westminster-c64.asm) references only these named constants.
//
//-----------------------------------------------------------------------------

#importonce

.const CHARSET_BASE       = $3800       // RAM charset image (char-base slot 7); above the installer, clear of the $1000/$1800 char-ROM shadow.
.const CHAR_ROM           = $D000       // Uppercase/graphics character ROM, visible when CHAREN = 0.
.const CHAR_ROM_SIZE      = $0800       // 2 KB -- the full 256-glyph uppercase/graphics set.

.const PROCESSOR_PORT     = $01         // 6510 processor port (memory banking).
.const CHAREN_CLEAR_MASK  = %11111011   // AND mask that clears CHAREN (bit 2) to bank char ROM in at $D000.

.const VIC_MEMORY_CONTROL = $D018       // VIC-II memory-pointer register.
.const VIC_MEMORY_VALUE   = $1E         // Matrix %0001 (screen $0400) + char field %111 (charset $3800).
