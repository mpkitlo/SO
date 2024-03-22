align           8
section .bss
number:         resq N

align           8
section .data
spinlock:       times N dq -1

align           8
section .text
global core
extern get_value
extern put_value

clear_stack:
        pop     rax                             ;zrzucam wynik na rax
        mov     rsp, rbx                        ;naprawiam wskaznik stacka

        pop     r15                             ;przywracam rejestry ktore trzeba przywrocic przed koncem programu
        pop     rbx
        pop     rbp

        ret

core:
        push    rbp                             ;indeks
        push    rbx                             ;zapisany poczatkowy stan stackus
        push    r15                             ;pomocnicze przed callami

        mov     rbx, rsp                      
        xor     rbp, rbp                

.loop1:
        movzx   eax, BYTE [rsi + rbp]           ;zapisuje kolejny element napisu na rejestr

        cmp     rax, 0x00
        je      clear_stack
;done
check_0_9:
        sub     al , 48                         ;sprawdzam czy liczba jest z przedialu 0-9
        cmp     al, 9                           ;jesli tak to wrzucam ja na stacka 
        ja      check_0_9.nxt 
        push    rax

        .nxt:
        add     al, 48

; ;done
check_n:
        cmp     al, 110                         ;sprzawdzma czy char to 'n'
        jne     check_add
        push    rdi                             ;wrzucam na stos numer rdzenia 

;done
check_add:
        cmp     al, 43                          ;sprawdzam czy char to '+'
        jne     check_mul
        pop     rcx                             ;zrzucam ze stacka i dodaje do kolejnego elementu 
        add     [rsp], rcx

;done
check_mul:
        cmp     al, 42                          ;sprawdzam czy char to '*'
        jne     check_sub
        pop     rdx                             ;zrzucam 2 elemnty ze stacka a nastepnie jest mnoze
        pop     rcx                             ;i wrzucam ponownie na stacka
        imul    rdx, rcx
        push    rdx                             

;done
check_sub:
        cmp     al, 45                          ;sprawdzam czy char to '-'
        jne     check_B
        neg     QWORD  [rsp]                    ;wykonuje negcje arytmetyczna na wierzchu stacka

;done
check_B:
        cmp     al, 66                          ;sprawdzam czy char to 'B'
        jne     check_C
        pop     rcx                             
        cmp     QWORD [rsp], 0                  ;sprawdzam czy po zrzuceniu elementu wierzch jest nie zerowy
        je      check_C                         
        add     rbp, rcx                        ;jesli tak to dodaje do indeksy po napisie 

;done
check_C:
        cmp     al, 67                          ;sprawdzam czy char to 'C'
        jne     check_D
        pop     rcx                             ;porzucam pierwszy element stacka

;done
check_D:
        cmp     al, 68                          ;sprawdzam czy char to 'D'
        jne     check_E 
        push    QWORD [rsp]                     ;duplikuje gore stacka

;done
check_E:
        cmp     al, 69                          ;spradzam czy char to 'E'
        jne     check_G
        pop     rcx                             ;zemieniam 1 element z 2 na stacku                     
        xchg    [rsp], rcx
        push    rcx

;done
check_G:
        cmp     al, 71                          ;spradzam czy char to 'G'
        jne     check_S                         

        push    rdi                             ;zapamietuje rdi, rsi zeby call ich nie zepsół
        push    rsi                             

        mov     r15, rsp                        ;zapamietuje wskaznik na stacku
        and     rsp, -16                        ;wyrunwuje stack

        call    get_value                       ;wywołuje funkcje get_value

        mov     rsp, r15                        ;cofam wskaznik na stacka
        pop     rsi                             ;cofam rdi, rsi ze stacka
        pop     rdi

        push    rax                             ;wrzucam na stacka wynik funkcja call

        jmp     end

check_S:
        cmp     al, 83                          ;spradzawm czy char to 'S'
        jne     check_P

        lea     rdx, [rel number]               ;wczytuje tablice z liczabmi do przekazania
        lea     rcx, [rel spinlock]             ;wczytauje tablice ktora mowi na co czekam

        pop     rax                             ;core z ktorym sie wymieniam    

        pop     QWORD [rdx + (8*rdi)]           ;ładuje co chce przekazac drugiemu watkowi
        mov     QWORD [rcx + (8*rdi)], rax      ;pokazuje na swoim indeksie z kim chce sie wymienic

.count_loop:
        cmp     QWORD [rcx + (8*rax)], rdi      ;spradzam czy core na ktory czekam czeka na mnie
        jne     check_S.count_loop

        push    QWORD [rdx + (8*rax)]           ;ładuje na stack liczbe z gory stosu drugiego cora
        push    -1                              ;zamieniam że tamten core juz na mnie nie czeka
        pop     QWORD [rcx + (8*rax)]
    
.count_loop2:
        cmp     QWORD [rcx + (8*rdi)], -1       ;spradzam czy ja dalej czekam
        jne     check_S.count_loop2

        jmp     end

;done
check_P:    
        cmp     al, 80                          ;sprawdzam czy char to 'P'
        jne     end                             
        pop     rcx                             ;zrzucam liczbe ze stosu ktora bedzie 2 arguemntem funkcji

        push    rdi                             ;zachowuje rdi i rsi na stosie
        push    rsi

        mov     r15, rsp                        ;zapisuje stan stosu przed callem
        and     rsp, -16                        ;wyrównuje stos
        mov     rsi, rcx                        ;wczytuje drugi argument

        call    put_value                       ;wywołuje funkcje zewnętrzną put_value

        mov     rsp, r15                        ;przywracam pocztakowym stan stosu sprzed calla

        pop     rsi                             ;wracam rsi i rdi ze stosu
        pop     rdi     
end:
        inc     rbp                             ;zwiekszam indeks po napisie 
        jmp     core.loop1


