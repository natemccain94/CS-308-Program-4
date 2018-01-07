; Nate McCain
; Assembly Program 4
; April 25, 2017
; This is the source code for a function to be called from a C program.
; The C program calls "void sqrtX(void)"
; Values are hard-coded into the assembly file. To view the result, just 
; enable a breakpoint at the bottom of the file (there is a comment indicating
; where to place it).

.586
.MODEL FLAT
.STACK 4096

.DATA
accuracy REAL4 0.00001	; This is for the while loop condition.
two DWORD 2				; This is for the operations requiring division.

number REAL4 68.9234		; This number can be changed.
result REAL4 ?			; This will hold the result of Newton's Algorithm.

.CODE
;**************************************************************************************
; void sqrtX(void)
_sqrtX PROC
	finit			; Initialize the stack
	fld number		; Push upper onto the stack with the value of number.
	fld1			; Push lower onto the stack with the value 1.
	fld st(1)		; Push temp onto the stack with the value of upper.
	fsub st, st(1)	; temp = temp - lower
	jmp mainLoop	; jump to the main loop.
					; The stack only consists of:
						; st: temp
						; st(1): lower
						; st(2): upper
mainLoop:
	fcomp accuracy			; (upper + lower) > 0.00001? Temp is removed from the stack.
	fstsw ax				; Copy condition code bits to AX.
	sahf					; Shift condition code bits to flags.
	jna endOfWork			; jump if the condition is no longer true.

	fld st(1)				; guess is pushed onto the stack with the value of upper.
	fadd st, st(1)			; guess = guess + lower
	fidiv two				; guess = guess/2
	
	fld st					; temp = guess
	fmul st, st(1)			; temp = temp * guess

	fcomp number			; (guess * guess) > number? temp is removed from the stack.
	fstsw ax
	sahf
	ja conditionMet			; go here if the condition is true,
	jmp conditionNotMet		; else go here.

; if ((guess * guess) > number)
conditionMet:
	fstp st(2)				; upper = guess
	jmp prepareToRepeatLoop
; else
conditionNotMet:
	fstp st(1)				; lower = guess
	jmp prepareToRepeatLoop

; Prepares the stack for the conditional at the beginning of the while loop.
prepareToRepeatLoop:
	fld st(1)				; temp = upper, temp is pushed onto stack.
	fsub st, st(1)			; temp = temp - lower
	jmp mainLoop

; The final calculation, and a place to put a breakpoint to check the result.
endOfWork:
	fadd					; stack is cleared and the sum of upper and lower are pushed onto it.
	fidiv two				; (upper + lower) / 2
	fstp result				; result now holds (upper + lower) / 2, the stack is empty.
	fld result				; This allows a check of the result (include a breakpoint here, and then click "step into").
	mov eax, 0				; This is just to help as an extra statement.
	ret

_sqrtX ENDP
;**************************************************************************************

END
