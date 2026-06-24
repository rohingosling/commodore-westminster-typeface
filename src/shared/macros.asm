//-----------------------------------------------------------------------------
// Shared, target-agnostic install macros (Commodore VIC-20 + 64).
//
// No machine-specific literal lives in this file (design decision D-7):
//
// - Both macros take the charset base, ROM source, byte counts, and 
//   overlay-table label as PARAMETERS, so the VIC-20 main reuses this 
//   file unchanged. 
//
// - The only hard-coded addresses here are the two zero-page scratch pointers 
//   below, which are free on BOTH the C64 and the VIC-20 and are used only 
//   during install, before the installer RTSes back to BASIC.
//
//-----------------------------------------------------------------------------

#importonce

// Zero-page scratch pointers ($FB/$FC and $FD/$FE are free on both machines).

.const ZP_SOURCE      = $FB    // 16-bit source pointer      ($FB/$FC).
.const ZP_DESTINATION = $FD    // 16-bit destination pointer ($FD/$FE).


//-----------------------------------------------------------------------------
// copy_charset_rom
//
// block-copy byte_count bytes from source to destination with a true 16-bit 
// page-walking loop, so it is correct for transfers larger than 256 bytes 
// (the C64 copies 2 KB, the VIC-20 copies 512 bytes). byte_count must be a 
// whole number of 256-byte pages.
//-----------------------------------------------------------------------------

.macro copy_charset_rom(source, destination, byte_count) {

    .errorif ((byte_count & $FF) != 0), "copy_charset_rom: byte_count must be a multiple of 256."

    lda #<source                     // ZP_SOURCE -> source.
    sta ZP_SOURCE
    lda #>source
    sta ZP_SOURCE + 1
    lda #<destination                // ZP_DESTINATION -> destination.
    sta ZP_DESTINATION
    lda #>destination
    sta ZP_DESTINATION + 1

    ldx #>byte_count                 // X = number of 256-byte pages to copy.
    ldy #$00
page:
    lda (ZP_SOURCE),y                // Copy one page (256 bytes) via Y = 0..255.
    sta (ZP_DESTINATION),y
    iny
    bne page
    inc ZP_SOURCE + 1                // Step both pointers to the next page.
    inc ZP_DESTINATION + 1
    dex
    bne page
}


//-----------------------------------------------------------------------------
// overlay_glyphs
//
// walk the generated overlay table and stamp each redefined glyph into the 
// RAM charset at  charset_base + screen_code * 8, computed with a TRUE 16-bit 
// add (low byte, then high byte with carry) so high screen codes land on the 
// correct page. Each record is 9 bytes: one screen-code byte plus eight glyph 
// bytes. The loop bound is the assemble-time constant record_count 
// (the generated <LABEL>_COUNT), and never a sentinel scan.
//-----------------------------------------------------------------------------

.macro overlay_glyphs(charset_base, table, record_count) {

    lda #<table                      // ZP_SOURCE -> first record.
    sta ZP_SOURCE
    lda #>table
    sta ZP_SOURCE + 1

    ldx #record_count                // X = records remaining.
record:
    ldy #$00
    lda (ZP_SOURCE),y                // A = screen code (record byte 0).

    sta ZP_DESTINATION               // ZP_DESTINATION = screen_code * 8 (16-bit).
    lda #$00
    sta ZP_DESTINATION + 1
    asl ZP_DESTINATION
    rol ZP_DESTINATION + 1
    asl ZP_DESTINATION
    rol ZP_DESTINATION + 1
    asl ZP_DESTINATION
    rol ZP_DESTINATION + 1

    lda ZP_DESTINATION               // ZP_DESTINATION += charset_base (16-bit add).
    clc
    adc #<charset_base
    sta ZP_DESTINATION
    lda ZP_DESTINATION + 1
    adc #>charset_base
    sta ZP_DESTINATION + 1

    inc ZP_SOURCE                    // Advance ZP_SOURCE to the first glyph byte.
    bne glyph_start
    inc ZP_SOURCE + 1
glyph_start:

    ldy #$00                         // Copy the 8 glyph bytes into the charset.
glyph:
    lda (ZP_SOURCE),y
    sta (ZP_DESTINATION),y
    iny
    cpy #$08
    bne glyph

    lda ZP_SOURCE                    // Advance ZP_SOURCE past the 8 glyph bytes
    clc                              // to the next record's screen-code byte.
    adc #$08
    sta ZP_SOURCE
    bcc next_record
    inc ZP_SOURCE + 1
next_record:

    dex
    bne record
}
