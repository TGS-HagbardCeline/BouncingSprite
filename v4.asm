*=$0801
;BASIC "2025 SYS2061"
!byte $0b,$08,$e9,$07,$9e,$32,$30,$36,$31,$00,$00,$00
    
    lda #$80        ;store value for 
    sta $29         ;the sprite pattern
    jsr $ff7e       ;clear screen
    sta $d000       ;store $d7 as initializing x coordinate for sprite 0
    stx $07f8       ;store $01 as sprite pointer for sprite 0 
    stx $d015       ;enable sprite 0
    stx $d017       ;expand x for sprite 0
    stx $d01d       ;expand y for sprite 0
    tay         
--  ldx #$02        ;create sprite from $0040 to $007e
-   lda $29,x       ;load pattern ($80,$00,$01)
    dey
    sta $35,y       ;store pattern into rows $01-$13
    lda #$ff
    sta $40,x       ;first row $00
    sta $7c,x       ;last row $14
    dex
    bpl -
    cpy #$7e
    bne --
    sty $d027       ;set sprite 0 colour to light blue
    pha             ;oldbyte for clearing sprite on stack
    
st  cpy $d012       ;wait until rasterline $ff is reached
    bne st  
    
    pla             ;load old byte of sprite from stack
    sta $40,x       ;clear moving pixel      

s0  inc $d000       ;sprite 0 x coordinate +/-1
    ldx $d000
    cpx $02         ;is sprite moving over the border $ff/$00?
    bne s2
s1  inc $d010       ;yes, change the 8 bit of the x coordinate
s2  cpx #$28        ;is sprite at left/right border?
    bne +
    lda $d010       ;check if bit 8 of x coordinate is set
s3  beq +
    lda s0          ;swap INC/DEC
    eor #$20
    sta s0
    sta s1
    eor #$1e        ;swap BPL/BMI
    sta s3
    lda $2
    eor #$ff        ;swap border $ff/$00 for 8 bit of x coordinate
    sta $02
    lda s2+1        ;swap left/right border
    eor #$30
    sta s2+1

+   ldx #$02        ;handle inner sprite and y movement
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
    sta $d001       ;store y coordinate of sprite 0

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
    
    jmp st          ;jump to next step

bl
!byte $32,$02,$02
bh
!byte $d0,$16,$13
