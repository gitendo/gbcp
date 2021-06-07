;;;
;;; $Log: DECOMP.ASM $
;;;

; History:
;
; 1.0:    Release from Jens Ch. Restermeier. The author of the original
;         code.
;         The code was done for GBDK assembler.
; 1.1:    Changed the code into RGBDS assembler.
;         Optimized the code. This might not always be faster but it was
;         faster in the tests I did.
;         Most of the optimizations I did was unrolling the loops to update
;         the double of data pr loop.
;         I changed a bit in the RLE word handling. Moving all push/pops
;         outside the loop. Also changed the code there to use HL for
;         memory access, before it was using DE and therefor needed a INC DE
;         Updated with the small improvements I did to the compression.
;
; 1.2:    Optimize a small bit. Thanks to Jeff Frohwein for spotting this.
;         It was mainly JP's that was replaced with JR's (12 of them) Things
;         I forgot when optimizing the old code.
;         There was also two places where "3 * inc A" and "4 * inc A" could
;         be replaced with "AdD a, x". Stupid me :)
;
; 1.3:    Fixed a few bugs that appeared when I unrolled some of the loops.
;         I never experienced these bugs, but they where there..
;         The decompress code was also optimized again. I had to re-arreange
;         some of the functions called from decompress. So some help
;         functions HAS to appear before the decompress function (because of
;         JR...)
;         The main thing that was optimized was that WE know that some of
;         the functions would minimum handle X data sets. Before I just
;         increased the counter for this. This was changed to code that just
;         handles the minimum number of data. Less counting but uses more
;         space.



;decompress:
; ============================================================================
;  This function decompresses data compressed with comp.c .
;  Input: hl = source; de = dest
; ============================================================================
;  return:
;     de -> next byte after the data..can be used for several decompressions
;     hl -> byte after the compressed chunk
;     bc -> number of bytes used from the compressed chunk




.SECTION "GBCOMPRESS DECOMPRESS" FREE

; string copy
stringCopy:
      and     63
      inc     a
      ld      b,a
      srl     b                 ; Make it even
      jr      NC, _notOdd1
      ld      a,[de]            ; Ups it was odd before
      inc     de
      ld      [hl+],a
_notOdd1:
      jr      Z, dLoop          ; Ups it was only one
_dc1:
      ld      a,[de]
      inc     de
      ld      [hl+],a

      ld      a,[de]
      inc     de
      ld      [hl+],a

      dec     b
      jr      z, dLoop

      ld      a,[de]
      inc     de
      ld      [hl+],a

      ld      a,[de]
      inc     de
      ld      [hl+],a

      dec     b
      jr      z, dLoop

      ld      a,[de]
      inc     de
      ld      [hl+],a

      ld      a,[de]
      inc     de
      ld      [hl+],a

      dec     b
      jr      z, dLoop

      ld      a,[de]
      inc     de
      ld      [hl+],a

      ld      a,[de]
      inc     de
      ld      [hl+],a

      dec     b
      jr      nz,_dc1

      ld      a,[de]   			; load command
      bit     7,a
      jr      nz,stringRepeat           ; string functions
      bit     6,a
      jp      nz,RLEWord

      jr      RLEByte

stringRepeat:
      inc     de
      bit     6,a
      jr      nz,stringCopy
; string repeat
      and     63
; Add 4 to count...NOT, we know that min is 4 so lets handle those 4..
; before entering the loop
      ld      b, a

      ld      a,[de]
      inc     de
      add     l
      ld      c, a

      ld      a,[de]
      inc     de
      adc     h
      push    de

      ld      d, a
      ld      e, c

.REPT 4
      ld      a,[de]
      ld      [hl+],a
      inc     de
.ENDR

      srl     b                 ; Make it even
      jr      NC, _notOdd_dr1

      ld      a,[de]            ; Ups it was odd before
      ld      [hl+],a
      inc     de
_notOdd_dr1:
      jr      Z, _strDone       ; Ups it was only one
_dr1:
      ld      a,[de]
      ld      [hl+],a
      inc     de

      ld      a,[de]
      ld      [hl+],a
      inc     de

      dec     b
      jr      z, _strDone

      ld      a,[de]
      ld      [hl+],a
      inc     de

      ld      a,[de]
      ld      [hl+],a
      inc     de

      dec     b
      jr      nz, _dr1

_strDone:
      pop     de

      ld      a,[de]   			; load command
      bit     7,a
      jr      nz,stringRepeat           ; string functions
      bit     6,a
      jr      nz,RLEWord
      jr      RLEByte

decompress:
      push    hl
; Lets swap de and hl...for speed...
      ld      a, e
      ld      e, l
      ld      l, a

      ld      a, h
      ld      h, d
      ld      d, a

dLoop:ld      a,[de]   			; load command
      bit     7,a
      jr      nz,stringRepeat           ; string functions
      bit     6,a
      jr      nz,RLEWord

RLEByte:

; RLE byte
      and     63                        ; calc counter
      jr      Z, decompressDone        	; if zero then we are done.

      inc     de

; Add 2 to count...NOT, we know that min is 2 so lets handle those 2..
; before entering the loop
;    add 2
      ld      b,a
      ld      a,[de]
      inc     de
.REPT 2
      ld      [hl+],a
.ENDR

      srl     b                  ; Make it even
      jr      NC, _notOdd2
      ld      [hl+],a            ; Ups it was odd before
_notOdd2:
      jr      Z, dLoop        	 ; Ups it was only one
_db1:
      ld      [hl+],a
      ld      [hl+],a
      dec     b
      jr      z, dLoop

      ld      [hl+],a
      ld      [hl+],a
      dec     b

      jr      z, dLoop

      ld      [hl+],a
      ld      [hl+],a
      dec     b

      jr      nz,_db1

      ld      a,[de]			; load command
      bit     7,a
      jr      nz,stringRepeat           ; string functions
      bit     6,a
      jr      nz,RLEWord
      jr      RLEByte

; RLE word
RLEWord:
      inc     de
      and     63
; Add 3 to count...NOT, we know that min is 3 so lets handle the first 2,
; before entering the loop
;      add   3
      inc     a

      ld      c, a

      ld      a,[de]          ; load word into bc
      ld      b, a
      inc     de
      ld      a,[de]
      push    de
      ld      e, a
      ld      d, b

.REPT 2
      ld      a,d             ; store word
      ld      [hl+],a
      ld      a,e
      ld      [hl+],a
.ENDR

_dw2:
      ld      a,d             ; store word
      ld      [hl+],a
      ld      a,e
      ld      [hl+],a
      dec     c
      jr      Z, _doneRLEWord

      ld      a,d             ; store word
      ld      [hl+],a
      ld      a,e
      ld      [hl+],a
      dec     c
      jr      nz, _dw2

_doneRLEWord:
      pop     de
      inc     de

      ld      a,[de]   ; load command
      bit     7,a
      jp      nz,stringRepeat           ; string functions
      bit     6,a
      jr      nz,RLEWord
      jr      RLEByte

decompressDone:
      pop     bc
; Sub bc from DE, result into bc
; and swap de and hl...
      inc     de        ; DE was NOT increased after last the END byte was
                        ; read
      ld      a, e
      ld      e, l
      ld      l, a

      sub     c
      ld      c, a

      ld      a, d
      ld      d, h
      ld      h, a

      sbc     b
      ld      b, a
; Lets swap de and hl again :)
      ret

.ENDS
