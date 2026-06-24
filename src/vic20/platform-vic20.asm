//-----------------------------------------------------------------------------
// Commodore VIC-20 (unexpanded) platform constants.
//
// All VIC-20-specific addresses and magic values live here, keeping macros.asm
// machine-agnostic (design decision D-7). 
//
// The main (westminster-vic20.asm) references only these named constants.
//
//-----------------------------------------------------------------------------

#importonce

.const CHARSET_BASE           = $1400     // RAM charset, full 256-glyph set at $1400-$1BFF (clear of the program below and the screen at $1E00).
.const CHAR_ROM               = $8000     // VIC-I uppercase/graphics ROM (always CPU-visible; no banking).
.const CHAR_ROM_SIZE          = $0800     // 2 KB = the full 256-glyph set, so reverse-video codes and the $A0 cursor (a reverse-space) render correctly.

.const FRETOP_LOW             = $33       // BASIC string-allocation pointer (FRETOP), low byte -- strings grow DOWN from here.
.const FRETOP_HIGH            = $34       // BASIC string-allocation pointer (FRETOP), high byte.
.const BASIC_TOP_LOW          = $37       // BASIC top of memory (MEMSIZ), low byte -- the value CLR resets FRETOP to.
.const BASIC_TOP_HIGH         = $38       // BASIC top of memory (MEMSIZ), high byte.
.const MEMSIZ_LOW             = $0283     // KERNAL MEMSIZ, low byte (kept in step with $37/$38).
.const MEMSIZ_HIGH            = $0284     // KERNAL MEMSIZ, high byte.

.const VIC_CONTROL            = $9005     // VIC-I control: high nibble = screen/colour base, low nibble = char base.
.const VIC_CONTROL_HIGH_MASK  = $F0       // AND mask: preserve the screen/colour high nibble (region-agnostic).
.const VIC_CONTROL_LOW_NIBBLE = $0D       // ORA value: low nibble $D -> char base $1400 (RAM).
