//-----------------------------------------------------------------------------
// Commodore VIC-20 Westminster charset installer (main).
//
// - Targets the UNEXPANDED machine. 
//
// - Loads at $1001 via a hand-emitted BASIC stub (Kick Assembler has no VIC-20 
//   upstart macro). 
//
// - Lowers the BASIC memory ceiling to protect the font, copies the full 2 KB 
//   char ROM ($8000-$87FF) into RAM at $1400, overlays the redefined 
//   Westminster glyphs (codes $00-$3F), points the VIC-I char base at $1400 
//   via a $9005 read-modify-write, and RTSes to BASIC so the font persists at 
//   the READY. prompt. 
//
// - The full 256-glyph copy means reverse-video codes and the $A0 cursor 
//   render correctly. Exact register sequence.
//
// Build:
//   java -jar KickAss.jar src/vic20/westminster-vic20.asm -libdir src/shared -o dist/westminster-vic20.prg
//
//-----------------------------------------------------------------------------

#import "platform-vic20.asm"
#import "macros.asm"

*=$1001


//-----------------------------------------------------------------------------
// Hand-emitted BASIC stub:  10 SYS <install>
//
// The stub is a fixed 12 bytes, so the entry address is a compile-time 
// constant (SYS_ENTRY).
//
// - The SYS digits are produced from that constant with toIntString (never 
//   hand-typed), and the .errorif at install verifies the real entry label
//   matches it. 
//
// - So a layout change or wrong digit count fails the build (R-5). 
//   A forward-label toIntString cannot be used here: its digit-string length
//   would depend on the very label it positions, which Kick Assembler's flex
//   passes cannot resolve. The link word points at the end-of-program marker.
//
//-----------------------------------------------------------------------------

.const SYS_DIGIT_COUNT = 4                                             // Entry $100D is a 4-digit decimal (range 4096-8191).
.const SYS_ENTRY       = $1001 + 2 + 2 + 1 + SYS_DIGIT_COUNT + 1 + 2   // link+line+token+digits+eol+end = $100D.

basic_line:
        .word basic_end                  // Link to the next BASIC line (the end marker).
        .word 10                         // Line number 10.
        .byte $9e                        // SYS token.
        .text toIntString(SYS_ENTRY)     // Decimal ASCII digits of the entry address.
        .byte $00                        // End of line.
basic_end:
        .word $0000                      // End of program.


//-----------------------------------------------------------------------------
// install
//
// The installer entry point reached via the BASIC SYS stub.
//-----------------------------------------------------------------------------

install:

        .errorif (install != SYS_ENTRY), "VIC-20 SYS stub: install != SYS_ENTRY (wrong digit count?)."

        lda #<CHARSET_BASE               // FR-10: lower BASIC memory ceiling FIRST so string/array
        sta FRETOP_LOW                   // growth cannot reach the font. FRETOP ($33/$34) is the
        sta BASIC_TOP_LOW                // live string-allocation pointer (strings grow down from it);
        sta MEMSIZ_LOW                   // MEMSIZ ($37/$38) is what CLR resets FRETOP to; $0283/$0284
        lda #>CHARSET_BASE               // is the KERNAL copy. All three are lowered to $1400 so the
        sta FRETOP_HIGH                  // protection holds both now and after any later CLR/RUN.
        sta BASIC_TOP_HIGH
        sta MEMSIZ_HIGH

        copy_charset_rom(CHAR_ROM, CHARSET_BASE, CHAR_ROM_SIZE)

        overlay_glyphs(CHARSET_BASE, WESTMINSTER_OVERLAY, WESTMINSTER_OVERLAY_COUNT)

        lda VIC_CONTROL                  // FR-7 / NFR-6: $9005 read-modify-write,
        and #VIC_CONTROL_HIGH_MASK       // preserving the screen/colour high nibble
        ora #VIC_CONTROL_LOW_NIBBLE      // and setting the low nibble to $D ($1400).
        sta VIC_CONTROL
        rts                              // FR-8: back to BASIC; the font persists.


//-----------------------------------------------------------------------------
// Generated Westminster overlay table, placed immediately after the code (well
// below the $1400 charset region).
//-----------------------------------------------------------------------------

#import "charset.asm"


// NFR-8 (VIC-20 analogue): the installer image (stub + code + table) must not
// reach into the charset RAM at $1400.

.errorif (* > CHARSET_BASE), "Installer image overruns the charset region at $1400 (NFR-8)."
