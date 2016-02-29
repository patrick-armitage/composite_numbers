TITLE Composite Numbers

; Author:              Patrick Armitage   
; Date:                02/11/2016
; Description: A MASM program which receives as input the number of composite 
;              number terms to be displayed, and prints them in rows of 10,
;              ensuring each number is not prime and printing however many
;              numbers the user originally specified in aligned columns.

INCLUDE Irvine32.inc

.data
programmer  BYTE  "Patrick Armitage",0
ec_desc     BYTE  "**EC: Align the output columns.",0
intro_1     BYTE  "Composite Numbers       Programmed by ",0
intro_2     BYTE  "Enter the number of composite numbers"
            BYTE  "  you would like to see.",0dh,0ah
            BYTE  "I'll accept orders for up to 400 composites.",0
prompt      BYTE  "Enter the number of composites to display [1 .. 400]: ",0
outofrange  BYTE  "Out of range.  Try again.",0
LOWERLIMIT  EQU   1    ; lowest valid number user is allowed to enter
UPPERLIMIT  EQU   400  ; highest valid number user is allowed to enter
prime_nums  DWORD 2,3,5,7,11,13,17,19 ; prime numbers less than sqrt of 500
PRIME_LEN   EQU   8                   ; length of array for looping
num_terms   DWORD ?    ; user enters
ch_counter  DWORD 0    ; number of terms printed per line
curr_num    DWORD 4    ; start at 4 since 1, 2, and 3 are all prime
has_factor  DWORD 0
num_written DWORD 0
sm_space    BYTE  "   ",0
md_space    BYTE  "    ",0
lg_space    BYTE  "     ",0
average     DWORD ?  ; must be calculated
remainder   DWORD 0  ; start at zero for comparison later on
goodbye_1   BYTE  "Results certified by ",0
goodbye_2   BYTE  "  Goodbye.",0
period      BYTE  ".",0

.code

;########## INTRODUCTION PROCEDURE
introduction PROC
  ; Introduce this program
  mov   edx, OFFSET intro_1
  call  WriteString
  mov   edx, OFFSET programmer
  call  WriteString
  call  CrLf
  mov   edx, OFFSET ec_desc
  call  WriteString
  call  CrLf
  call  CrLf
; Explain the rules of entering valid number of terms
  mov   edx, OFFSET intro_2
  call  WriteString
  call  CrLf
  call  CrLf
  ret
introduction ENDP

;########## GET NUMBER OF TERMS
; prompt user for number of terms and validate user input is within range
getUserData PROC
get_terms:
  mov   edx, OFFSET prompt
  call  WriteString
  call  ReadInt
  mov   num_terms, eax      ; save the number of terms
  call  validate
  ret
getUserData ENDP

;########## VALIDATE TERMS
; check if user input is valid, and reissue prompt until valid input is given
validate PROC
validate_terms:
  mov   eax, num_terms
  cmp   eax, LOWERLIMIT     ; validates num_terms is >= 1
  jl    invalid
  cmp   eax, UPPERLIMIT
  jg    invalid             ; validates num_terms is <= 400
  jmp   valid         ; if this line is reached, move to calculations
invalid:
  mov   edx, OFFSET outofrange
  call  WriteString
  call  CrLf
  jmp   reissue_prompt
valid:
  ret
reissue_prompt:  ; repeats prompt issued originally until valid input is given
  mov   edx, OFFSET prompt
  call  WriteString
  call  ReadInt
  mov   num_terms, eax
  jmp   validate_terms
validate ENDP

;########## SHOW COMPOSITES
; Calculate and each composite number that can be found within num_terms
; Print the results to screen in rows of 10, and print CrLf after each row
showComposites PROC
  call  CrLf
show_terms:
  call  isComposite
  mov   eax, num_written  ; isComposite increments num_written on each write
  cmp   eax, num_terms    ; if num_written == num_terms, we exit the program
  je    ending
  mov   eax, curr_num
  add   eax, 1            ; increment curr_num by 1 each loop
  mov   curr_num, eax
  mov   eax, ch_counter
  cmp   eax, 10  ; once 10 numbers have been printed, print an endline
  je    endline
  jmp   show_terms
; Call at the end of each row of ten terms
endline:
  call CrLf
  mov  ch_counter, 0  ; move counter back to zero to print next line of 10
  jg   show_terms
ending:
  ret
showComposites ENDP

;########## SHOW COMPOSITES
; Checks curr_num to see if it is a composite number by comparing to a list of
; prime numbers.  If it is equal to any in the list, skip that number.  Else, if
; curr_num is divisible by any number in the list with no remainder, it is not a
; prime number but is composite (divides by other numbers than itself and 1)
isComposite PROC
  mov   ecx, (PRIME_LEN - 1)    ; we use 1 less for zero-based index
check_num:
  mov   esi, OFFSET prime_nums  ; set esi to pointer of array address
  mov   ebx, [esi + 4 * ecx]    ; add 4 * ecx to esi for each iteration
                                ; since they are DWORDs (4 bytes each)
  mov   eax, curr_num
  cmp   eax, ebx
  jl    continue                ; if curr_num < prime_num, skip to next prime
  je    compEnd                 ; if curr_num == prime_num, it's not composite
  mov   eax, curr_num
  cdq
  xor   edx, edx                ; prepare edx for division
  div   ebx
  cmp   edx, 0                  ; if remainder == 0, we have found a factor
  je    found_factor            ; once a factor is found we can mark has_factor
  cmp   ecx, 0                  ; if it's our last loop, exit, else continue
  je    compEnd
  jmp   continue
found_factor:
  mov   eax, 1                  ; once one factor is found, we know curr_num is
  mov   has_factor, eax         ; a composite number
  jmp   continue
write_num:
  mov   eax, curr_num
  call  WriteDec
  cmp   eax, 10                 ; to align columns, write a large space for small
  jl    write_lg_space          ; nums, medium for 10s, and small for 100s
  cmp   eax, 100
  jl    write_md_space
  jmp   write_sm_space
finish_write:
  mov   eax, 0
  mov   has_factor, eax        ; set has_factor back to 0 for next number
  mov   eax, ch_counter
  add   eax, 1                 ; increment ch_counter to track 10 nums per line
  mov   ch_counter, eax
  inc   num_written            ; increment num_written until we reach num_terms
  jmp   compEnd
write_sm_space:
  mov   edx, OFFSET sm_space
  call  WriteString
  jmp   finish_write
write_md_space:
  mov   edx, OFFSET md_space
  call  WriteString
  jmp   finish_write
write_lg_space:
  mov   edx, OFFSET lg_space
  call  WriteString
  jmp   finish_write

compEnd:
  cmp   has_factor, 0         ; if has_factor > 0, we need to write the num
  jg    write_num
  mov   eax, 0
  mov   has_factor, eax
  ret
continue:
  cmp   ecx, 0
  je    compEnd               ; if it's the last loop exit the loop
  sub   ecx, 1                ; decrement ecx manually since no loop call
  jmp   check_num
isComposite ENDP

;########## GOODBYE
; Print parting message to user
farewell PROC
  call  CrLf
  call  CrLf
  mov   edx, OFFSET goodbye_1
  call  WriteString
  mov   edx, OFFSET programmer
  call  WriteString
  mov   edx, OFFSET period
  call  WriteString
  mov   edx, OFFSET goodbye_2
  call  WriteString
  call  CrLf
  ret
farewell ENDP

; call each of the major functions sequentially and exit the program
main PROC
  call  introduction
  call  getUserData
  call  showComposites
  call  farewell

  exit  ; exit to operating system
main ENDP

END main
