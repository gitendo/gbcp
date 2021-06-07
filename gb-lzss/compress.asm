Import Copy

SECTION "Decompress", HOME

;; assumes HL contains src
;;         DE contains dest
Decompress::
.chunk		LD A, [HLI]			; get flags
		LD B, A				; put flags in B
		LD C, 8				; 8 commands per chunk
.command	LD A, [HLI]			; get next byte
		BIT 0, B			; is this flag hi?
		JR NZ, .literal			; if so, we have a literal
		AND A				; otherwise, check for EOF
		RET Z
		LDH [$FE], A			; store length to copy
		LD A, [HLI]			; get -offset
		PUSH HL				; backup read location
		ADD E				; newLoc = E + (-offset)
		LD L, A
		LD H, D
		JR c, .nowrap
		DEC H
.nowrap		LDH A, [$FE]			; get length
                PUSH BC				; backup flags
		LD B, A
		CALL Copy			; HL = SRC, DE = DEST, B = LEN
		POP BC
		POP HL				; get pointer to compressed data
		JR .nextbyte
.literal	LD [DE], A
		INC DE
.nextbyte	SRL B				; move to next flag
		DEC C				; one less command
		JR NZ, .command
		JR .chunk
