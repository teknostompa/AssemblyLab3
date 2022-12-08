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

putText:
    pushq   %r14
    leaq    outBuf, %r14    # loads outbuf to r14
    addq    outPos, %r14    # moves outbuf to outpos
putTextChar:
    movb    (%rdi), %al     # move char at pointer to byte register
    cmpb    $0, %al       # Check if char is null
    je      putTextDone     # If so, jump to end
    movb    %al, (%r14)     # Move char to outBuf
    incq    outPos          # Add to Out Pointer
    incq    %r14            # move pointer to buffer forwards
    incq    %rdi            # move pointer to string forwards
    call    checkBuffPos    # check so that buffer is not full
    jmp     putTextChar     # Loop
putTextDone:
    popq    %r14
    ret

outImage:
    pushq   %r14
    leaq    outBuf, %r14    # loads outbuf to r14
    addq    outPos, %r14    # moves outbuf to outpos
    movb    $0, (%r14)      # move breakline to last char
    movq    $outBuf, %rdi   # rdi = parameter
    call    puts            # puts(buf)
    movq    $0, outBuf      # empty outBuf
    movq    $0, outPos      # empty outBuf
    popq    %r14
    ret

inImage:
    movq    $inBuf, %rdi    # rdi: IN1 = buffert lägg input-buffer i %rdi.
    movq    $64, %rsi       # rsi: IN2 = size, lägg storleken för inmätning tecken i %rsi
    movq    stdin, %rdx     # rdx: IN3 = stdin (stream)
    call    fgets           # fgets(buffert, size, stdin) = läser från tangetbordet
    movq    $0, inPos       # nollställa inData-position
    ret

getInt:
    pushq    %r13
    pushq    %r14
    pushq    %r15
    leaq    inBuf, %r14     # loads inbuf to r14
    addq    inPos, %r14     # moves inbuf to inpos
    XORq    %rax, %rax      # nollställ rax
    movq    $10, %r15       # flytta 10 till r15 för *10 senare
getIntSpaceLoop:
    movb    (%r14), %bl     # flytta första karaktären till BL
    cmpb    $' ', %bl       # Jämför med ' '
    jne continueGetInt
    incq    %r14            # nästa käraktär
    incq    inPos           # nästa käraktär
    jmp getIntSpaceLoop
continueGetInt:
    cmpb    $'-', %bl       # Jämför med '-'
    jne     checkPositiveInt
    movq    $1, %r13        # sätt r13 till 1 om talet är negativt
    incq    inPos           # hoppa till nästa karaktär
    incq    %r14            # hoppa till nästa karaktär
checkPositiveInt:
    cmpb    $'+', %bl       # Jämför med '+'
    jne     getIntDigit
    incq    inPos           # hoppa till nästa karaktär
    incq    %r14            # hoppa till nästa karaktär
getIntDigit:
    movb    (%r14), %bl     # ladda nästa karaktär
    cmpb    $48, %bl        # kolla om karaktären är en siffra
    jl      getIntDone      # hoppa till slut
    cmpb    $57, %bl        # kolla om karaktären är en siffra  
    jg      getIntDone      # hoppa till slut
    mulq    %r15            # gånger 10 för att det är decimalt.
    addq    %rbx, %rax      # lägg till den nya karaktären i RAX
    subq    $48, %rax       # 0 = 48, så vi tar bort det för att få den sanna siffran
    incq    inPos           # hoppa till nästa karaktär
    incq    %r14            # hoppa till nästa karaktär
    jmp     getIntDigit     # loop
getIntDone:
    cmpq    $1, %r13        # kolla om nummret var negativt
    jne returnInt           # hoppa till return
    negq    %rax            # om det var negativt, negera
returnInt:
    popq    %r15
    popq    %r14
    popq    %r13
    ret

getText:
    pushq   %r14
    XORq    %rax, %rax      # nollställ rax då den används som räknare
    leaq    inBuf, %r14     # ladda in buff
    addq    inPos, %r14     # sätt buffertposition till nuvarande
    leaq    (%rdi), %rdi    # ladda returnbuffert till rdi
    movb    (%r14), %bl     # ladda nästa karaktär
    cmpb    $' ', %bl       # kolla om space före
    jne     getTextLoop     # om inte, läser vi
    incq    %r14            # öka inbuffer
    movb    (%r14), %bl     # ladda nästa karaktär
getTextLoop:
    cmpb    $0, %bl         # kolla om 0, isåfall är vi klara
    je  getTextReturn
    movb    %bl, (%rdi)     # flyttta karaktär till returnbuffert
    incq    %rax            # öka rax, antal siffror som är laddade
    incq    %rdi            # flytta returnbuffert frammåt
    incq    %r14            # flytta inbuffert frammåt
    incq    inPos           # öka inpos
    movb    (%r14), %bl     # ladda nästa karaktär
    cmpq    %rax, %rsi      # kolla om vi läst maxkäraktärer, rsi är från caller
    jne     getTextLoop     # fortsätt
getTextReturn:
    popq    %r14
    ret

getChar:
    pushq   %r14
    leaq    inBuf, %r14     # ladda in buff
    addq    inPos, %r14     # sätt buffertposition till nuvarande
    movq    (%r14), %rax    # flytta käraktären till return
    incq    inPos           # öka inpos
    popq    %r14
    ret

getInPos:
    movq    inPos, %rax #flytta inpos till returnvärde
    ret

setInPos:
    movq    %rdi, inPos     # sätt inpos till invariablel.
    cmpq    $0, %rdi        # input min = 0
    jl      setBuffPosZero
    cmpq    $64, %rdi       # input max = 0
    jg      setBuffPosMax
    ret

putInt:
    pushq   %r13
    pushq   %r15
    XORq    %r13, %r13      # nollställ r13 för att den räknar senare
    movq    $10, %r15       # sätt nämnaren i förväg
    cmpq    $0, %rdi        # kolla om nummret är negativt
    jge     putIntNumber    # om det är positivt så kollar vi nummer direkt
    pushq   %rdi            # pusha rdi då putchar förstör
    cmpq    $0, outPos      # kolla om + skrevs ut innan
    jle     negativeContinue
    decq    outPos          # om outpos är större än 0 så ligger + före\
negativeContinue:           # så vi minskar med 1 för att skriva över
    movq    $45, %rdi       # flytta '-' till rdi
    incq    outPos          # öka outpos igen
    call    putChar         # kalla putChar
    popq    %rdi            # poppa rdi dp putchar förstör
    negq    %rdi            # negera talet så att vi nu har positivt
putIntNumber:
    XORq    %rdx, %rdx      # divq använder rdx:rax som 128bit tal
    movq    %rdi, %rax      # täljaren i rax
    divq    %r15            # nämnaren i r15 
    movq    %rax, %rdi      # kvot hamnar i rax
    pushq   %rdx            # rest hamnar i rdx, pusha för att vi får baklänges
    incq    %r13            # räknare för antal siffror
    cmpq    $0, %rdi        # om rdi är 0 behöver vi inte dela längre
    jg  putIntNumber
putIntFinal:
    popq    %rdi            # poppa ut tal i rätt ordning
    addq    $48, %rdi       # lägg till basen för tal, 48 (Ascii)
    call    putChar         # kalla putchar
    decq    %r13            # räknare för antal siffror
    cmpq    $0, %r13        # kolla om vi tagit alla siffror
    jne putIntFinal         
putIntReturn:
    popq    %r15
    popq    %r13
    ret

putChar:
    pushq   %r14
    call    checkBuffPos    # kolla så att buffern inte är full
    leaq    outBuf, %r14    # lägg buffern i r14
    addq    outPos, %r14    # flytta fram aktuell position
    movb    %dil, (%r14)    # flytta karaktären till bufferten
    incq    outPos          # outPos++
    popq    %r14
    ret

getOutPos:
    movq    outPos, %rax    # sätt output-buffertposition  till OUT-register
    ret

setOutPos:
    movq    %rdi, outPos    # sätta out-buffertposition till outPos variable.
    cmpq    $0, %rdi        # output min = 0
    jl      setBuffPosZero
    cmpq    $64, %rdi       # output max = 64
    jg      setBuffPosMax
    ret

setBuffPosZero:
    movq    $0, %rdi        # Hjälpfunktion för setoutPos
    ret

setBuffPosMax:
    movq    $64, %rdi       # Hjälpfunktion för setoutPos
    ret

 checkBuffPos:
    pushq   %rbx
    movq outPos, %rbx       # flytta outpos till rbx
    cmpq $64, %rbx          # kolla om buffern är full
    jl returnToFunction
    call outImage           # skriv ut om buffern är full
returnToFunction:
    popq    %rbx
    ret
