/* Lab3 */
    .data
inBuf:      .space 64
outBuf:     .space 64
inPos:      .quad   0
outPos:     .quad   0
intCount:   .quad   0




    .text
    .global putText # Tom DONE
    .global outImage # DONE
    .global inImage # done->BUG
    .global getInt # Tom
    .global getText # Tom
    .global getChar # Tom
    .global getInPos # done
    .global setInPos # done

    .global putInt # Tom
    .global putChar # Tom DONE
    .global getOutPos # done
    .global setOutPos # done
    /*Extra funktioner */
    .global setBuffPosZero # done
    .global setBuffPosMax # done



putText: # DONE->TO TEST
   # pushq   %RDI             # no need to push/pop, it's already secured
    pushq   %R14            /*pushes registers to stack */
    pushq   %R15
    XORq    %rax, %rax      # nollställ %rax
    movb    (%RDI), %AL     # move first char at pointer to byte register
    movq    outPos, %r14
    leaq    outBuf, %R14    # hämtar adressen outBuf till R14
    addq    outPos, %R14
    cmpb    $0, %AL
    jne putTextChar
    incq    outPos
    movb    (%RDI), %AL
putTextChar:
    cmpb    $0x0, %AL       # Check if char is null
    je      putTextDone     # If so, jump to end
    movb    %AL, (%R14)     # Move char to outBuf
    incq    outPos          # Add to Out Pointer
    incq    %R14            # move pointer to buffer forwards
    incq    %RDI            # move pointer to string forwards
    movb    (%RDI), %AL     # move char at pointer to byte register
    call    checkBuffPos
    jmp     putTextChar     # Loop
putTextDone:
    popq    %R15            # pops registers from stack/retrieve registry value
    popq    %R14
   # movq    $0, %R14        # needed?
   # popq    %RDI            # no need to push/pop
    ret

outImage: # Done->Tested
/* print-> puts(buffert) */
    pushq   %rdx           
    pushq   %rsi           
    pushq   %rax            
    pushq   %rdi            # might not need
    pushq   %r14            
    leaq    outBuf, %R14
    addq    outPos, %R14
    movb    $'\n', (%R14)
    incq    outPos
    XORq    %rsi, %rsi
    movq    (outPos), %rdx
    addq    $outBuf, %rsi
    movq    $1, %rdi
    movq    $1, %rax
    syscall
    movq    $0, outBuf      # empty outBuf
    movq    $0, outPos      # empty outBuf
    popq    %r14
    popq    %rdi            # might not need    
    popq    %rax            
    popq    %rsi    
    popq    %rdx    
    ret

inImage: # DONE->MUST TEST WITH getInt, getChar..
    movq    $inBuf, %rdi    # rdi: IN1 = buffert lägg input-buffer i %rdi.
    movq    $64, %rsi       # rsi: IN2 = size, lägg storleken för inmätning tecken i %rsi
    movq    stdin, %rdx     # rdx: IN3 = stdin (stream)
    call    fgets           # fgets(buffert, size, stdin) = läser från tangetbordet
    movq    $0, inPos       # nollställa inData-position

    ret

getInt:
    pushq   %R13 
    pushq   %R14 
    pushq   %R15
    leaq    inBuf, %R14 # ladda in buff
    addq    inPos, %R14
    XORq    %RAX, %RAX  # nollställ rax
    movq    $10, %R15   # flytta 10 till r15 för *10 senare
getIntSpaceLoop:
    movb    (%R14), %BL # flytta första karaktären till BL
    cmpb    $' ', %BL    # Jämför med ' '
    jne continueGetInt
    incq    %R14
    incq    inPos
    jmp getIntSpaceLoop
continueGetInt:
    jne     checkNegativeInt
    incq    %R14        # hoppa till nästa karaktär
    incq    inPos       # hoppa till nästa karaktär
    movb    (%R14), %BL # ladda nästa karaktär
checkNegativeInt:
    cmpb    $45, %BL    # Jämför med '-'
    jne     checkPositiveInt
    movq    $1, %R13    # sätt r13 till 1 om talet är negativt
    incq    inPos       # hoppa till nästa karaktär
    incq    %R14        # hoppa till nästa karaktär
checkPositiveInt:
    cmpb    $43, %BL    # Jämför med '+'
    jne     getIntDigit
    incq    inPos       # hoppa till nästa karaktär
    incq    %R14        # hoppa till nästa karaktär
getIntDigit:
    movb    (%R14), %BL # ladda nästa karaktär
    cmpb    $48, %BL    # kolla om karaktären är en siffra
    jl      getIntDone  # hoppa till slut
    cmpb    $57, %BL    # kolla om karaktären är en siffra  
    jg      getIntDone  # hoppa till slut
    mulq    %R15        # gånger 10 för att det är decimalt.
    addb    %BL, %AL    # lägg till den nya karaktären i RAX
    subq    $48, %RAX   # 0 = 48, så vi tar bort det för att få den sanna siffran
    incq    inPos       # hoppa till nästa karaktär
    incq    %R14        # hoppa till nästa karaktär
    jmp     getIntDigit # loop
getIntDone:
    cmpq    $1, %R13    # kolla om nummret var negativt
    jne returnInt       # hoppa till return
    negq    %RAX        # om det var negativt, negera
returnInt:
    popq    %R15
    popq    %R14 
    popq   %R13 
    ret

getText:
    pushq   %R14 
    pushq   %R15 
    pushq   %RBX 
    XORq    %R15, %R15
    XORq    %RAX, %RAX
    XORq    %RBX, %RBX
    leaq    inBuf, %R14 # ladda in buff
    addq    inPos, %R14
    leaq    (%rdi), %rdi
    movb    (%R14), %BL # ladda nästa karaktär
    cmpb    $32, %BL
    jne     getTextLoop
    incq    %r14
    movb    (%R14), %BL # ladda nästa karaktär
getTextLoop:
    cmpq    $10, %RBX
    je  getTextReturn
    movq    %RBX, (%rdi)
    incq    %RAX
    incq    %rdi
    incq    %r14
    incq    inPos
    movb    (%R14), %BL # ladda nästa karaktär
    cmpq    %RAX, %rsi
    jne     getTextLoop
getTextReturn:
    movq    $'\n', (%rdi)
    subq    %RAX, %rdi
    decq    %rdi
    popq    %rBX
    popq    %r15
    popq    %r14
    ret

getChar:
    ret

getInPos:
    movq    inPos, %rax
    ret

#---------- setInPos ----------#
setInPos: # DONE->TO TEST
    movq    %rdi, inPos     # set buffertposition to inPos variable.
    cmpq    $0, %rdi
    jl      setBuffPosZero
    cmpq    $64, %rdi
    jg      setBuffPosMax
    ret
#-----------------------------#


putInt: # On-going
/* Register-info
    %RDI = in number
    
 */            
    pushq   %R15 /*pushes registers to stack */
    pushq   %R14
    pushq   %R13
    XORq    %rax, %rax
    XORq    %R13, %R13
    movq    $10, %r15
    # om det är negativt
    cmpq    $0, %rdi
    jge     putIntNumber
    pushq   %rdi
    movq    outPos, %r14
    cmpq    $-1, outPos
    je      negativeContinue
    decq    outPos
negativeContinue:
    movq    $45, %rdi
    incq    outPos
    call    putChar
    popq    %rdi
    negq    %rdi
    # om det är negativt
putIntNumber:   #resten är posititvt
    XORq    %rdx, %rdx
    movq    %rdi, %rax
    divq    %r15    # siffran hamnar i rdx
    movq    %rax, %rdi  # talet delat på 10 är i rax
    pushq   %rdx
    incq    %r13
    cmpq    $0, %rdi
    jg  putIntNumber
putIntFinal:
    popq    %rdi
    addq    $48, %rdi
    call    putChar
    decq    %r13
    cmpq    $0, %r13
    jne putIntFinal
putIntReturn:
    popq   %R13
    popq   %R14
    popq   %R15
    ret

putChar: # DONE->TO TEST
/*Rutinen ska lägga tecknet c i utbufferten och flytta fram aktuell position i den ett steg.
Om bufferten blir full när getChar anropas ska ett anrop till outImage göras, så att man
får en tömd utbuffert att jobba vidare mot.
Parameter: tecknet som ska läggas i utbufferten (c i texten)
 */
    call    checkBuffPos
    leaq    outBuf, %r14    # r10 hold addr of outBuf
    addq    outPos, %r14    # flytta fram aktuell position
    movb    %dil, (%r14)    # put IN1-param in outBuf
    incq    outPos          # outPos++
    ret
notOutImage:
    ret

getOutPos: # DONE->TO TEST
    movq    outPos, %rax    # sätt output-buffertposition  till OUT-register
    ret

setOutPos: # DONE->TO TEST
    movq    %rdi, outPos     # sätta out-buffertposition till outPos variable.
    cmpq    $0, %rdi
    jl      setBuffPosZero
    cmpq    $64, %rdi
    jg      setBuffPosMax
    ret

setBuffPosZero:
    movq    $0, %rdi
    ret

setBuffPosMax:
    movq    $64, %rdi
    ret

 checkBuffPos:
    pushq %rbx
    movq outPos, %rbx
    cmpq $64, %rbx
    jl returnToFunction
    call outImage
returnToFunction:
    popq %rbx
    ret
