; Implementation of the minilzo decompress routine in Gameboy assembler
;
; Michael Hope August 1998 - version 0.21
;	<michaelh@earthling.net>
;	<mlh47@student.canterbury.ac.nz>
;	http://www.pcmedia.co.nz/~michaelh
;
; Based on minilzo-1.04 (15 Mar 1998)
;   by 	Markus F.X.J. Oberhumer
;      	<markus.oberhumer@jk.uni-linz.ac.at>
;	http://wildsau.idv.uni-linz.ac.at/mfx/lzo.html
;
; Note:  Uses the 'maccer' development macro pre-processor and GBDK-2.0
;

; Version 0.1	254790
; 		  0.2   268136 (result of fixing rrgb)

; 9th Jun, 2021 - converted to RGBASM format with minor optimizations by tmk
;                 check https://github.com/gitendo/gbcp for more!


	PUSHS

SECTION "Unpack Vars",HRAM
;ip:
;	DS	2
m_pos:
	DS	2
	
	POPS


; hl - packed data
; de - where to unpack
lzo_decompress::
	ld	a,[hl]
	cp	17+1
	jr	c,label_1
	inc	hl
	sub	17
	ld	c,a
	ld	b,0
	cp	4
	jp	c,match_next

label_2:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	c
	jr	nz,label_2
	jr	first_literal_run

label_1:
while_TEST_IP_TEST_OP:
	ld	a,[hl+]
	ld	c,a
	ld	b,0
;	inc	hl
	cp	16
	jp	nc,match
	cp	0
	jr	nz,t_not_eq_0a

	push	de
	ld	d,h
	ld	e,l
	ld	h,b
	ld	l,c
	ld	bc,255

while_IP_EQ_ZERO:
	ld	a,[de]
	or	a
	jr	nz,while_IP_EQ_ZERO_end
	add	hl,bc
	inc	de
	jr	while_IP_EQ_ZERO

while_IP_EQ_ZERO_end:
	ld	c,15
	add	hl,bc
	ld	a,[de]
	ld	c,a
	add	hl,bc
	ld	b,h
	ld	c,l
	ld	h,d
	ld	l,e
	pop	de
	inc	hl

t_not_eq_0a:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	ld	a,[hl+]
	ld	[de],a
	inc	de
	ld	a,[hl+]
	ld	[de],a
	inc	de
	xor	a
	cp	b
	jr	z,label_4_quick

label_4:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,label_4
	jr	label_4_end

label_4_quick:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	c
	jr	nz,label_4_quick
label_4_end:

first_literal_run:
	ld	a,[hl+]
	ld	c,a
	ld	b,0
;	inc	hl
	cp	16
	jr	nc,match
	push	de		; de is now m_pos
	push	bc
	ld	a,e
;	sub	1
	dec	a
	ld	e,a
	ld	a,d
	sbc	8
	ld	d,a
	srl	b
	rr	c
	srl	b
	rr	c
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
	ld	a,[hl+]
	ld	c,a
	ld	b,0
;	inc	hl
	srl	b
	rr	c
	srl	b
	rr	c
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
	pop	bc
	pop	de
	push	hl
	ld	h,d
	ld	l,e
	ld	a,[hl+]
	ld	[de],a
	inc	de
	ld	a,[hl+]
	ld	[de],a
	inc	de
	ld	a,[hl+]
	ld	[de],a
	inc	de
	ld	a,l
	ldh	[m_pos],a
	ld	a,h
	ldh	[m_pos+1],a
	pop	hl	
	jp      match_done

while_TEST_IP_TEST_OP2:
match:
	ld	a,c
	and	192
	or	b
	jr	z,t_not_gteq_64
	push	de		; Free these up
	push	bc
	dec	de
	srl	b
	rr	c
	srl	b
	rr	c
	ld	b,0
	ld	a,c
	and	7
	ld	c,a
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
	ld	c,[hl]
	ld	b,0
	inc	hl
	or	a
	rl	c
	rl	b
	or	a
	rl	c
	rl	b
	or	a
	rl	c
	rl	b
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
	pop	bc
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c
	dec	bc
	ld	a,e
	ldh	[m_pos],a
	ld	a,d
	ldh	[m_pos+1],a
	pop     de
	jp	copy_match

t_not_gteq_64:
	bit	5,c
	jr	z,t_not_gteq_32
	ld	b,0
	ld	a,c
	and	31
	ld	c,a
	cp	0
	jr	nz,t_not_eq_0b
	push	de
	ld	d,h
	ld	e,l
	ld	h,b
	ld	l,c
	ld	bc,255

while_ip_eq_0:
	ld	a,[de]
	or	a
	jr	nz,while_ip_eq_0_end
	add	hl,bc
	inc	de
	jr	while_ip_eq_0

while_ip_eq_0_end:
	ld	c,31
	add	hl,bc
	ld	a,[de]
	ld	c,a
	add	hl,bc
	ld	b,h		; Restore
	ld	c,l
	ld	h,d
	ld	l,e
	pop	de
	inc	hl     

t_not_eq_0b:
	push	de		; Prepare
	push	bc
	dec	de
;	ld	c,[hl]
;	inc	hl
;	ld	b,[hl]
;	inc	hl
	ld	a,[hl+]
	ld	c,a
	ld	a,[hl+]
	ld	b,a
	srl	b
	rr	c
	srl	b
	rr	c
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
	ld	a,e
	ldh	[m_pos],a
	ld	a,d
	ldh	[m_pos+1],a
	pop	bc
	pop	de
	jp	exit_else

t_not_gteq_32:
	bit	4,c
	jr	z,t_not_gteq_16
	push	de
	push	bc
	ld	a,c
	and	8
	ld	b,a
	ld	c,0
	or	a
	rl	c
	rl	b
	or	a
	rl	c
	rl	b
	or	a
	rl	c
	rl	b
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
	pop	bc
	ld	a,c
	and	7
	ld	c,a
	ld	b,0
	cp	0
	jr	nz,t_not_eq_0

while_ip_eq_0b:
	xor	a
	cp	[hl]
	jr	nz,while_ip_eq_0_exitb
	ld	a,255
	add	c
	ld	c,a
;	ld	a,0
	adc	b
	sub	c	
	ld	b,a
	inc	hl
	jr	while_ip_eq_0b

while_ip_eq_0_exitb:
	ld	a,7
	add	c
	ld	c,a
;	ld	a,0
	adc	b
	sub	c
	ld	b,a
	ld	a,[hl+]
	add	c
	ld	c,a
;	ld	a,0
	adc	b
	sub	c
	ld	b,a
;	inc	hl

t_not_eq_0:
	push	bc
;	ld	c,[hl]
;	inc	hl
;	ld	b,[hl]
;	inc	hl
	ld	a,[hl+]
	ld	c,a
	ld	a,[hl+]
	ld	b,a
	srl	b
	rr	c
	srl	b
	rr	c
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
	ld	a,e
	ldh	[m_pos],a
	ld	a,d
	ldh	[m_pos+1],a
	pop	bc
	pop	de		; From way above
	ldh	a,[m_pos]
	cp	e
	jr	nz,not_eof_found
	ldh	a,[m_pos+1]
	cp	d
	jp	z,eof_found

not_eof_found:
;	ld	a,e
;	sub	0
;	ld	e,a
	ld	a,d
;	sbc	$40
	sub	$40
	ld	d,a
	jr	exit_else

t_not_gteq_16:
	push	de
	push	bc
	dec	de
	srl	b
	rr	c
	srl	b
	rr	c
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
	ld	a,[hl+]
	ld	c,a
	ld	b,0
;	inc	hl
	or	a
	rl	c
	rl	b
	or	a
	rl	c
	rl	b
	ld	a,e
	sub	c
	ld	e,a
	ld	a,d
	sbc	b
	ld	d,a
	push	hl
	ld	h,d
	ld	l,e
	pop	bc
	pop	de
	ld	a,[hl+]
	ld	[de],a
	inc	de
	ld	a,[hl+]
	ld	[de],a
	inc	de
	ld	a,l
	ldh	[m_pos],a
	ld	a,h
	ldh	[m_pos+1],a
	pop	hl
	jr	match_done

exit_else:
copy_match:
	push	hl
	ldh	a,[m_pos]
	ld	l,a
	ldh	a,[m_pos+1]
	ld	h,a
	ld	a,[hl+]
	ld	[de],a
	inc	de
	ld	a,[hl+]
	ld	[de],a
	inc	de
	xor	a
	or	b
	jr	z,label_5_quick

label_5:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,label_5
	jr	label_5_end

label_5_quick:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	c
	jr	nz,label_5_quick

label_5_end:
	ld	a,l
	ldh	[m_pos],a
	ld	a,h
	ldh	[m_pos+1],a
	pop	hl

match_done:
	dec	hl
	dec	hl
	ld	a,[hl+]
	and	3
	ld	c,a
	ld	b,0
;        inc     hl
	inc	hl
	or	a
	jr	z,while_TEST_IP_TEST_OP2_exit

match_next:
	xor	a
	cp	b
	jr	z,label_6_quick

label_6:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,label_6
	jr	label_6_end

label_6_quick:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	c
	jr	nz,label_6_quick

label_6_end:
	ld	a,[hl+]
	ld	c,a
	ld	b,0
;	inc	hl
	jp	while_TEST_IP_TEST_OP2

while_TEST_IP_TEST_OP2_exit:
	jp	while_TEST_IP_TEST_OP

while_TEST_IP_TEST_OP_exit:
eof_found:
	ret
