*=$c000

    lda #0
    pha
    ldx #71
--  ldy #2
-   lda #255
    sta 16320,y
    sta 16380,y
    lda pattern,y
    dex
    sta 16309,x
    dey
    bpl -
    cpx #14
    bne --
    stx 53248+46
    sty 2047

    sta 53248+21
    sta 53248+23
    sta 53248+29
    
st  cpy 53248+18
    bne st
    
i0  inc 53248+15
    lda 53248+15
i1  cmp #208
    bne i2
    lda i0
    eor #32
    sta i0
    lda i1+1
    eor #226
    sta i1+1

i2  inc 53248+14
    lda 53248+16
    ldx 53248+14
i3  cpx #0
    bne i4
    eor #128
    sta 53248+16      
i4  cpx #40
    bne +
    and #255
i5  bpl +
    lda i2
    eor #32
    sta i2
    eor #254
    sta i5
    lda i3+1
    eor #255
    sta i3+1
    lda i4+1
    eor #48
    sta i4+1
    
+   ldx pattern+4
    pla
    eor 16320,x
    sta 16320,x
a0  inc pattern+2
    txa
    clc
a1  adc #3
    tax
    
    lda pattern+2
a2  cmp #19
    bne a3

    lda a0
    eor #32
    sta a0
    lda a1+1
    eor #254
    sta a1+1
    lda a2+1
    eor #18
    sta a2+1
        
a3  inc pattern+3
    lda pattern+3
a4  cmp #8
    beq a6
a5  cmp #16
    bne a7
a6  inx
a7  cmp #22
    bne +
    lda a3
    eor #32
    sta a3
    lda a4+1
    eor #15
    sta a4+1
    lda a5+1
    eor #31
    sta a5+1
    lda a6
    eor #34
    sta a6
    lda a7+1
    eor #21
    sta a7+1    

+   stx pattern+4
    lda pattern+3
    and #7
    tax
    lda #0
    sec
-   ror
    dex
    bpl -
    ldx pattern+4
    pha
    eor 16320,x
    sta 16320,x
    jmp st
    
pattern
!byte 128,  0,  1,  8,  4
