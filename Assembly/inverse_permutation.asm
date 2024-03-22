global inverse_permutation
        mask    equ     0x80000000              ; MAX_INT + 1

copy_and_xor:                                   ; funkcja bioraca aktualny element z tablicy i gasząca ostatni bit
        mov     ecx, [rsi + 4 * rdx]            ; biore wartosc z tablicy                       
        test    ecx, ecx                        ; sprawdzam znak liczby
        jns     copy_and_xor.dont               ; jesli jest dodatnia pomijam nastepny krok
        not     ecx                             ; jesli liczba jest ujemna to ja odwracam

.dont:   
        ret

exit_error1:                                    ; funkcja obsługująca niepoprawne dane
        mov     r9, rdx                         ; kopiuje indeks na którym spradzanie wejścia sie nie powiodło
        xor     rdx, rdx                        ; zeruje rejestr aby skorzystac z niego jako indeks

.loop1:                                         ; petla do odracania rzeczy ktore zmienilem podczas sprawdzania
        call    copy_and_xor                    
        cmp     rdx, r9                         ; porownuje indeks to miejsca gdzie zepsuło sie sprawdzanie wejścia
        je      exit_error1.exit_error2         ; jeśli już wszytsko poprawilem to ide do konca programu
        mov     r8d, [rsi + 4 * rcx]            ; odkrecam na przeciwny wszytskie bity ktore wczesniej zmienilem
        not     r8d                             ; odwracam liczbe
        mov     [rsi + 4 * rcx], r8d            ; zapisuje spowrotem ja na tablice
        inc     rdx                             ; zwiększam indeks                        
        jmp     exit_error1.loop1               ; skacze na początek pętli

.exit_error2:    
        xor     eax, eax                        ; zeruje eax bo program nie powiódł się i zwracam
        ret

inverse_permutation:                            ; głowna funkcja 
        xor     edx, edx                        ; zeruje rejestr rdx korzystam jako indeks
        cmp     edi, mask                       ; sprawdzam czy podana wielkość tablicy jest mniejsza niz MAX_INT
        ja      exit_error1.exit_error2         ; podana wielkosc tablicy jest za duza koniec
        test    edi, edi                        ; spradzam czy podana wielkosc jest 0 
        jz      exit_error1.exit_error2         ; podana wielkosc tablicy jest 0 koniec
        
.loop3:                                         ; petla sprawdzająca czy dane wejsciowe sa poprawne
        call    copy_and_xor                
        cmp     rcx, rdi                        ; sprawdzam czy element tablicy jest większy niż jej rozmiar
        jae     exit_error1                     ; jeśli tak to ide do sekcja obsługi wyjścia z błedem
        mov     r8d, [rsi + 4 * rcx]            ; kopiuje aktualny element tablicy
        test    r8d, r8d                        ; sprawdzam czy skopiowana liczba jest ujemna
        js      exit_error1                     ; jeśli tak to ide do sekcji obsługi wyjścia z błedem 
        not     r8d                             ; jeśli nie to odwracam liczbe
        mov     [rsi + 4 * rcx], r8d            ; wkładam spowrotem do tablicy
        inc     rdx                             ; zwiekszam indeks
        cmp     rdx, rdi                        ; porownuje z rozmiarem tablicy
        jne     inverse_permutation.loop3       ; jeśli indeks jest mniejszy od wielkosci to ponawiam pętle
        xor     r8d, r8d                        ; zeruje rejestry ktorę będe uzywał jako indeksy
        xor     edx, edx

.loop1:                                         ; głowna pętla
        mov     edx, [rsi + 4 * r8]             ; spisuje aktualny element z tablicy
        not     edx                             ; odwracam liczbe
        test    edx, edx                        ; sprawdzam czy aktualny element tablicy jest ujemny
        js      inverse_permutation.continue    ; jeśli tak to pomijam pomijam następną pętle
        mov     r10d, r8d                       ; spisuje indeks aktualnej iteracji

.loop2:
        call    copy_and_xor                    ; kopiuje wartosc z tablicy pod 2 indeksem
        mov     [rsi + 4 * rdx], r10d           ; nadpisuje wartosc pod 2 indeksem inna wartoscia
        mov     r10d, edx                       ; zapamiętuje poprzednia wartosc 2 indeksu                   
        mov     edx, ecx                        ; nadpisuje 2 indeks wartoscia pod tablica pod indeksem 1
        cmp     edx, r8d                        ; porownuje 1 indeks z 2 i powtarzam petle dopuki sa różne
        jne     inverse_permutation.loop2      
        mov     [rsi + 4 * r8], r10d            ; na koniec ostatnia wartosc cyklu podmieniam 

.continue:
        inc     r8d                             ; inkrementuje 1 indeks
        cmp     r8d, edi                        ; spradzam czy wychodze poza tablice        
        jne     inverse_permutation.loop1       ; jesli nie to powtarzam petle
        xor     eax, eax                        ; tutaj sekcja poprawnego wykonania programu
        inc     eax                             ; zeruje a nastpenie inkrementuje aby funckja zwrocila true
        ret







