; this is older / slower revision, use Vegas Stakes (USA, Europe) (SGB Enhanced).asm instead
; resourced by tmk
; visit Game Boy Compression Playground at https://github.com/gitendo/gbcp for more

; these should be located in HRAM
byte_FFD7:
	ds	1
byte_FFD8:
	ds	1


unhal:
	ld	a, e
	ld	[byte_FFD7], a
	ld	a, d
	ld	[byte_FFD8], a

loc_1E25:
	ld	a, [hl]
	cp	$FF
	ret	z
	and	$E0
	cp	$E0
	jr	nz, loc_1E3F
	ld	a, [hl]
	add	a, a
	add	a, a
	add	a, a
	and	$E0
	push	af
	ld	a, [hl+]
	and	3
	ld	b, a
	ld	a, [hl+]
	ld	c, a
	inc	bc
	jr	loc_1E47

loc_1E3F:
	push	af
	ld	a, [hl+]
	and	$1F
	ld	c, a
	ld	b, 0
	inc	c

loc_1E47:
	inc	b
	inc	c
	pop	af
	bit	7, a
	jr	nz, loc_1E92
	cp	$20
	jr	z, loc_1E66
	cp	$40
	jr	z, loc_1E72
	cp	$60
	jr	z, loc_1E85

loc_1E5A:
	dec	c
	jr	nz, loc_1E61
	dec	b
	jp	z, loc_1E25

loc_1E61:
	ld	a, [hl+]
	ld	[de], a
	inc	de
	jr	loc_1E5A

loc_1E66:
	ld	a, [hl+]

loc_1E67:
	dec	c
	jr	nz, loc_1E6E
	dec	b
	jp	z, loc_1E25

loc_1E6E:
	ld	[de], a
	inc	de
	jr	loc_1E67

loc_1E72:
	dec	c
	jr	nz, loc_1E79
	dec	b
	jp	z, loc_1E81

loc_1E79:
	ld	a, [hl+]
	ld	[de], a
	inc	de
	ld	a, [hl-]
	ld	[de], a
	inc	de
	jr	loc_1E72

loc_1E81:
	inc	hl
	inc	hl
	jr	loc_1E25

loc_1E85:
	ld	a, [hl+]

loc_1E86:
	dec	c
	jr	nz, loc_1E8D
	dec	b
	jp	z, loc_1E25

loc_1E8D:
	ld	[de], a
	inc	de
	inc	a
	jr	loc_1E86

loc_1E92:
	push	hl
	push	af
	ld	a, [hl+]
	ld	l, [hl]
	ld	h, a
	ld	a, [byte_FFD7]
	add	a, l
	ld	l, a
	ld	a, [byte_FFD8]
	adc	a, h
	ld	h, a
	pop	af
	cp	$80
	jr	z, loc_1EAC
	cp	$A0
	jr	z, loc_1EB7
	cp	$C0
	jr	z, loc_1EC9

loc_1EAC:
	dec	c
	jr	nz, loc_1EB2
	dec	b
	jr	z, loc_1ED5

loc_1EB2:
	ld	a, [hl+]
	ld	[de], a
	inc	de
	jr	loc_1EAC

loc_1EB7:
	dec	c
	jr	nz, loc_1EBE
	dec	b
	jp	z, loc_1ED5

loc_1EBE:
	ld	a, [hl+]
	push	hl
	ld	h, must contain table's address high byte
	ld	l, a
	ld	a, [hl]
	pop	hl
	ld	[de], a
	inc	de
	jr	loc_1EB7

loc_1EC9:
	dec	c
	jr	nz, loc_1ED0
	dec	b
	jp	z, loc_1ED5

loc_1ED0:
	ld	a, [hl-]
	ld	[de], a
	inc	de
	jr	loc_1EC9

loc_1ED5:
	pop	hl
	inc	hl
	inc	hl
	jp	loc_1E25

; make sure table is located at even offset ie. $3B00
table:
	db	$00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
	db	$08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
	db	$04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
	db	$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
	db	$02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
	db	$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
	db	$06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
	db	$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
	db	$01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
	db	$09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
	db	$05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
	db	$0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
	db	$03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
	db	$0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
	db	$07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
	db	$0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF
