*=$0801
;BASIC "2025 SYS2061"
!byte $0b,$08,$e9,$07,$9e,$32,$30,$36,$31,$00,$00,$00
    
    lda #$80        ;store value for 
    sta $29         ;the sprite pattern
    jsr $ff7e       ;clear screen
    sta $d00e       ;store $d7 as initializing x coordinate for sprite 7
    stx $07ff       ;store $01 as sprite pointer for sprite 7 
    tay         
--  ldx #$02        ;create sprite from $0040 to $007e
-   lda #$ff
    sta $40,x       ;first row $00
    sta $7c,x       ;last row $14
    lda $29,x       ;load pattern ($80,$00,$01)
    dey
    sta $35,y       ;store pattern into rows $01-$13
    dex
    bpl -
    cpy #$7e
    bne --
    sty $d02e       ;set sprite 7 colour to light blue
    
    sta $d015       ;enable sprite 7
    sta $d017       ;expand x for sprite 7
    sta $d01d       ;expand y for sprite 7

st  cpy $d012       ;wait until rasterline $ff is reached
    bne st  
    
s0  inc $d00e       ;sprite7 x coordinate +/- 1
    lda $d010       ;load bit 8 of x coordinate
    ldx $d00e
    cpx $02         ;is sprite moving over the border $ff/$00?
    bne s1
    eor #$80        ;yes, change the 8 bit of the x coordinate
    sta $d010      
s1  cpx #$28        ;is sprite at left/right border?
    bne +
    and #$ff        ;check if bit 8 of x coordinate is set
s2  bpl +
    lda s0          ;swap INC/DEC
    eor #$20
    sta s0
    eor #$fe        ;swap BPL/BMI
    sta s2
    lda $2
    eor #$ff        ;swap border $ff/$00 for 8 bit of x coordinate
    sta $02
    lda s1+1        ;swap left/right border
    eor #$30
    sta s1+1

+   lda $3b         ;load old byte of sprite
    ldx $3a         ;load old position within the sprite 
    sta $40,x       ;clear moving pixel      

    ldx #$02        ;handle inner sprite and y movement
-   lda $25,x       ;load coordinate
    ldy $08,x       ;load direction $00/$01
    bne +
    inc $25,x       ;INC coordinate
    cmp bh,x        ;is right/bottom border reached?
    bne ++
    dec $08,x       ;yes, swap direction
    beq ++
+   dec $25,x       ;DEC coordinate
    cmp bl,x        ;is left/top border reached?
    bne ++
    inc $08,x       ;yes, swap direction
++  dex
    bpl -
    sta $d00f       ;store y coordinate of sprite 7

    lda $27         ;calculate pixel position and store it into X
    asl             ;load y coordinate
    adc $27         ;and multiply it with 3
    tax
    
    lda $26
-   cmp #$08        ;load x coordinate
    bcc +           ;until x coordinate >7 
    inx             ;substract 8 and INC X
    sbc #$08
    bpl -

+   ldy $40,x       ;load current byte of sprite
    sty $3b         ;at calculated position
    stx $3a         ;and store the byte and position
    
    tay             
    lda #$00        ;take bit 0-2 of x coordinate
    sec             ;and calculate pixel position 
-   ror             ;within calculated byte
    dey             ;v=2^(7-x)
    bpl -
    ora $40,x       ;set moving pixel
    sta $40,x
    jmp st          ;jump to next step

bl
!byte $32,$02,$02
bh
!byte $d0,$16,$13
