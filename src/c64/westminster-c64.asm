//-----------------------------------------------------------------------------
// Commodore 64 Westminster charset installer (main).
//
// Loads at $0801 via BasicUpstart2. Copies the 2 KB uppercase/graphics char ROM
// into RAM at $3800, overlays the redefined Westminster glyphs, repoints the
// VIC-II character base ($D018 = $1E), and RTSes to BASIC so the font persists
// at the READY. prompt.
//
// Prints nothing, hooks no interrupt, leaves no resident code. Exact register
// sequence.
//
// Build:
//   java -jar KickAss.jar src/c64/westminster-c64.asm -libdir src/shared -o dist/westminster-c64.prg
//
//-----------------------------------------------------------------------------

#import "platform-c64.asm"
#import "macros.asm"

BasicUpstart2(install)


//-----------------------------------------------------------------------------
// install
//
// The installer entry point reached via the BASIC SYS stub.
//
//-----------------------------------------------------------------------------

install:

        sei                              // FR-9: no IRQs while I/O is banked out.
        lda PROCESSOR_PORT               // Save the processor port.
        pha
        and #CHAREN_CLEAR_MASK           // Clear CHAREN: bank char ROM in at $D000.
        sta PROCESSOR_PORT

        copy_charset_rom(CHAR_ROM, CHARSET_BASE, CHAR_ROM_SIZE)

        pla                              // Restore the processor port (I/O back at $D000).
        sta PROCESSOR_PORT
        cli                              // Re-enable IRQs.

        overlay_glyphs(CHARSET_BASE, WESTMINSTER_OVERLAY, WESTMINSTER_OVERLAY_COUNT)

        lda #VIC_MEMORY_VALUE            // Screen $0400 + charset $3800.
        sta VIC_MEMORY_CONTROL           // Repoint the VIC-II character base.
        rts                              // FR-8: back to BASIC; the font persists.


//-----------------------------------------------------------------------------
// Generated Westminster overlay table, placed immediately after the code (well
// below the $3800 charset region).
//-----------------------------------------------------------------------------

#import "charset.asm"


// NFR-8: the installer image (code + table) must not reach into the charset RAM.

.errorif (* > CHARSET_BASE), "Installer image overruns the charset region at $3800 (NFR-8)."
