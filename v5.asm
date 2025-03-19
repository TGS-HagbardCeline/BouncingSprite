*=$0801
;BASIC "2025 SYS2061"
!byte $0b,$08,$e9,$07,$9e,$32,$30,$36,$31,$00,$00,$00
    
    lda #$80        ;store value for 
    sta $29         ;the sprite pattern
    jsr $ff7e       ;clear screen, Y gets value $84
    sta $d000       ;store $d7 as initializing x coordinate for sprite 0
    stx $07f8       ;store $01 as sprite pointer for sprite 0 
    stx $d015       ;enable sprite 0
    stx $d017       ;expand x for sprite 0
    stx $d01d       ;expand y for sprite 0        

--  ldx #$02        ;create sprite from $0040 to $007e
-   lda $29,x       ;load pattern ($80,$00,$01)
    dey
    sta ($17),y     ;store pattern into rows $01-$13
    lda #$ff
    sta $40,x       ;first row $00
    sta $7c,x       ;last row $14
    dex
    bpl -
    cpy #$1e
    bne --

    sty $d027       ;set sprite 0 colour to light blue
    pha             ;old byte for clearing sprite on stack
    
st  cpy $d012       ;wait until rasterline $ff is reached
    bne st  
    
    pla             ;load old byte of sprite from stack
    sta $40,x       ;clear moving pixel      

    ldx #$03        ;handle inner sprite and x/y movement
    ldy $d010
-   lda $f7,x       ;load direction $00/$01
    bne +

    inc $1a,x       ;INC coordinate
    bne c0          ;is it 0 (only possible for x coordinate of sprite 0)
    iny             ;yes, handle $d010 
c0  lda $1a,x       ;load coordinate
    cmp bh,x        ;is right/bottom border reached?
    bne ++
    cpx #$00        ;could be border $00/ff from x coordinate
    bne d0
    cpy #$00        ;is it the real right border?
    beq ++
d0  dec $f7,x       ;yes, swap direction
    beq ++

+   dec $1a,x       ;DEC coordinate
    lda $1a,x       ;load coordinate
    cmp #$ff        ;is it $ff (only possible for x coordinate of sprite 0)
    bne c1
    dey             ;yes, handle $d010
c1  cmp bl,x        ;is left/top border reached?
    bne ++
    cpx #$00        ;could be border $00/ff from x coordinate
    bne d1
    cpy #$00        ;is it the real left border?
    bne ++
d1  inc $f7,x       ;yes, swap direction

++  sta $d000,x     ;store coordinate x/y of sprite 0
    dex
    bpl -
    sty $d010       ;store bit 8 of x coordinate

    lda $1d         ;calculate pixel position and store it into X
    asl             ;load y coordinate
    adc $1d         ;and multiply it with 3
    tax
    
    lda $1c
-   cmp #$08        ;load x coordinate
    bcc +           ;until x coordinate >7 
    inx             ;substract 8 and INC X
    sbc #$08
    bpl -

+   tay
    lda $40,x       ;load current byte of sprite at calculated position
    pha             ;and store it as old byte on stack
            
    lda #$00        ;take bit 0-2 of x coordinate
    sec             ;and calculate pixel position 
-   ror             ;within calculated byte
    dey             ;v=2^(7-y)
    bpl -
    ora $40,x       ;set moving pixel
    sta $40,x
    
    bne st          ;jump to next step

bl
!byte $18,$32,$02,$02
bh
!byte $28,$d0,$16,$13
