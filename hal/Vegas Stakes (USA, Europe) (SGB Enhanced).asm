; resourced by tmk
; visit Game Boy Compression Playground at https://github.com/gitendo/gbcp for more

; these should be located in HRAM
byte_CF00:
	ds	1
byte_CF01:
	ds	1


unhal:
	ld	a, e
	ld	[byte_CF00], a
	ld	a, d
	ld	[byte_CF01], a

loc_338B:
	ld	a, [hl]
	cp	$FF
	ret	z
	and	$E0
	cp	$E0
	jr	nz, loc_33A5
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
	jr	loc_33AD

loc_33A5:
	push	af
	ld	a, [hl+]
	and	$1F
	ld	c, a
	ld	b, 0
	inc	c

loc_33AD:
	inc	b
	inc	c
	pop	af
	bit	7, a
	jr	nz, loc_33FD
	cp	$20
	jr	z, loc_33CD
	cp	$40
	jr	z, loc_33DA
	cp	$60
	jr	z, loc_33EF

loc_33C0:
	dec	c
	jr	nz, loc_33C7
	dec	b
	jp	z, loc_338B

loc_33C7:
	ld	a, [hl+]
	call	loc_CF02
	jr	loc_33C0

loc_33CD:
	ld	a, [hl+]

loc_33CE:
	dec	c
	jr	nz, loc_33D5
	dec	b
	jp	z, loc_338B

loc_33D5:
	call	loc_CF02
	jr	loc_33CE

loc_33DA:
	dec	c
	jr	nz, loc_33E1
	dec	b
	jp	z, loc_33EB

loc_33E1:
	ld	a, [hl+]
	call	loc_CF02
	ld	a, [hl-]
	call	loc_CF02
	jr	loc_33DA

loc_33EB:
	inc	hl
	inc	hl
	jr	loc_338B

loc_33EF:
	ld	a, [hl+]

loc_33F0:
	dec	c
	jr	nz, loc_33F7
	dec	b
	jp	z, loc_338B

loc_33F7:
	call	loc_CF02
	inc	a
	jr	loc_33F0

loc_33FD:
	push	hl
	push	af
	ld	a, [hl+]
	ld	l, [hl]
	ld	h, a
	ld	a, [byte_CF00]
	add	a, l
	ld	l, a
	ld	a, [byte_CF01]
	adc	a, h
	ld	h, a
	pop	af
	cp	$80
	jr	z, loc_3419
	cp	$A0
	jr	z, loc_3424
	cp	$C0
	jr	z, loc_343C

loc_3419:
	dec	c
	jr	nz, loc_341F
	dec	b
	jr	z, loc_3448

loc_341F:
	ld	a, [hl+]
	ld	[de], a
	inc	de
	jr	loc_3419

loc_3424:
	dec	c
	jr	nz, loc_342B
	dec	b
	jp	z, loc_3448

loc_342B:
	ld	a, [hl+]
	push	bc
	ld	bc, 8

loc_3430:
	rra
	rl	b
	dec	c
	jr	nz, loc_3430
	ld	a, b
	pop	bc
	ld	[de], a
	inc	de
	jr	loc_3424

loc_343C:
	dec	c
	jr	nz, loc_3443
	dec	b
	jp	z, loc_3448

loc_3443:
	ld	a, [hl-]
	ld	[de], a
	inc	de
	jr	loc_343C

loc_3448:
	pop	hl
	inc	hl
	inc	hl
	jp	loc_338B

loc_CF02:
	ld	[de], a
	inc	de
	ret
