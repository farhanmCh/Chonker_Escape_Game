; ***********************************

; First, some assembler directives that tell the assembler:
; - assume a small code space
; - use a 100h size stack (a type of temporary storage)
; - output opcodes for the 386 processor
.MODEL small
.STACK 100h
.386

; Next, begin a data section
.data
	msg DB "CHONKER TERMINATED", 0	; first msg
	nSize DW ($ - msg)-1

	rockpos DB 66, 70, 49, 60, 76, 3, 1, 39, 14, 17, 2, 59, 16, 63, 69, 78, 11, 53, 43, 50
			DB 68, 54, 26, 72, 62, 34, 46, 74, 77, 19, 42, 57, 5, 1, 70, 48, 32, 10, 18, 16
			DB 60, 55, 22, 34, 79, 67, 11, 53, 37, 38, 33, 74, 72, 51, 78, 59, 54, 18, 3, 2
			DB 61, 8, 32, 60, 20, 52, 26, 3, 54, 39, 67, 23, 11, 62, 7, 55, 16, 74, 77, 69
			DB 39, 8, 3, 51, 74, 33, 79, 35, 42, 36, 18, 10, 77, 78, 61, 59, 57, 5, 54, 43
			DB 39, 51, 20, 52, 67, 21, 1, 76, 5, 4, 41, 17, 55, 33, 25, 18, 46, 62, 30, 45
			DB 7, 53, 68, 11, 33, 47, 20, 77, 56, 2, 6, 8, 23, 61, 78, 46, 60, 70, 75, 5
			DB 6, 25, 78, 63, 52, 19, 7, 15, 11, 38, 10, 67, 47, 79, 31, 58, 41, 71, 3, 77
			DB 32, 61, 10, 42, 57, 44, 19, 70, 26, 67, 9, 25, 11, 50, 52, 66, 28, 55, 63, 68
			DB 73, 6, 60, 7, 22, 10, 67, 49, 77, 44, 1, 61, 29, 47, 54, 19, 53, 62, 42, 2
			DB 55, 41, 21, 25, 65, 45, 72, 46, 23, 49, 33, 6, 22, 42, 78, 29, 27, 53, 28, 75
			DB 43, 48, 37, 27, 1, 64, 29, 28, 63, 41, 40, 25, 34, 26, 79, 72, 56, 73, 75, 21
			DB 52, 14, 2, 68, 66, 49, 44, 77, 47, 15, 42, 64, 69, 18, 50, 74, 5, 9, 10, 6
			DB 60, 66, 29, 71, 2, 75, 42, 17, 34, 49, 70, 67, 44, 19, 73, 38, 36, 30, 3, 51
			DB 56, 49, 38, 51, 17, 54, 11, 13, 25, 24, 7, 9, 76, 65, 37, 16, 15, 47, 53, 55
			DB 20, 67, 70, 19, 75, 13, 68, 24, 39, 49, 45, 16, 69, 35, 23, 34, 10, 54, 29, 62
			DB 62, 37, 30, 47, 78, 3, 73, 54, 23, 77, 60, 4, 20, 41, 50, 27, 35, 34, 61, 24
			DB 63, 76, 38, 46, 65, 29, 33, 77, 24, 55, 35, 17, 67, 69, 8, 53, 68, 56, 47, 18
			DB 31, 20, 33, 39, 5, 28, 53, 47, 27, 59, 78, 50, 43, 17, 70, 45, 22, 9, 1, 46
			DB 79, 45, 36, 32, 42, 72, 10, 64, 33, 74, 26, 63, 40, 35, 44, 24, 55, 54, 16, 59
	
	nSize2 DW ($ - rockpos)-1
	
 ; You'll want to make a few variable here.
 ; For example, to track the chonker's location on the screen.

	xpos DB 20h

; Next begins the code portion of the program.
; First, a few useful procedures are defined.
.code

; This procedure creates a 0.1 second delay.
; Make sure you understand how it works.

delay proc
	MOV CX, 01h
	MOV DX, 86A0h
	MOV AH, 86h
	INT 15h	; 1 seconds delay	
	RET
delay ENDP

; Write your own procedures below to reduce the amount of repetitive code in your program

set_cursor proc
    mov  dl, dl   ; dl contains the column
	mov  dh, dh   ; dh contains the row
    mov  bh, 0h   ; page number 
	mov  ah, 2h   ; AH=02h will set cursor position              
    int  10h      ; calls the software interrupt 
	ret
set_cursor endp

set_character proc
    mov al, al	  ; load AL with the ascii code for X	
	mov bh, 0h	  ; BH = page number
	mov bl, bl    ; color of character
	mov cx, 1	  ; CX = number of times to print the character
	mov ah, 09h   ; AH = 09h causes "write character and attribute at cursor location"
	int 10H		  ; calls the software interrupt
	ret
set_character endp

; This is the main procedure. The assembler knows to make this the entry point
_main PROC
; This is the start of the loop that will run continuously
	
; First, set various registers 
; It's important to set the segment registers.

	MOV DX, @data
	MOV DS, DX
	MOV SI, OFFSET rockpos

OuterLoop:
; draw some rocks
; first let's set the cursor position
	mov dl, byte ptr [SI]    ; store rock position in DL
	mov dh, 18h
	call set_cursor
	inc SI
	
; second let's write an R at the cursor position	
	mov AL, 'R'	  ; load AL with "R" character
	mov bl, 07h	  ; color of character
	call set_character

; scroll the screen
    mov bh, 0     ; attribute
    mov ch, 0     ; row top
    mov cl, 0     ; col left
    mov dh, 25    ; row bottom
    mov dl, 80    ; col right
	mov al, 1     ; number of lines to scroll
	mov ah, 06h   ; AH=06h will scroll screen 
    int 10h

; see if a rock hit the chonker
	mov dl, xpos  ; chonker column position
	mov dh, 0Ch	  ; chonker row position
	call set_cursor

	mov ah, 08h	  ; function call to read character at cursor position
	int 10h
	cmp al, 'R'   ; checks to see if chonker position is the same as the rock
	je terminate

; if chonker is safe, draw the chonker
; Your code to draw the chonker. Maybe another INT call?
	mov dl, xpos
	mov dh, 0Ch
	call set_cursor

	mov AL, 'X'   ; load AL with "R" character
	mov bl, 06h	  ; color of character
	call set_character

; We wait 0.1 second.	
	CALL delay

; If the "q" is pressed, end the program otherwise loop through the code again.
	mov AH, 1h 
	int 16h 
	cmp AL, 'q'     ; terminate if 'q' key has pressed     
	je terminate

;CHECK IF KEY WAS PRESSED.
	mov ah, 0bh
  	int 21h      ; RETURNS AL=0 if NO KEY PRESSED otherwise AL!=0 if KEY PRESSED.
  	cmp al, 0
  	je  noKey

;PROCESS KEY.        
;
; check if left or right key was pressed.
; Maybe an INT call for this?
; Use some program flow control logic to get
; to either the moveleft or the moveright section
; of code as needed.
	mov AH, 0h 
	int 16h 

	cmp AL, 'a' 
	je moveleft

	cmp AL, 'd'
	je moveright

noKey:
; Some code related to drawing the tunnel could go here.

	JMP OuterLoop

moveleft:
; some code about moving left could go here.
	dec xpos	
	JMP OuterLoop

moveright:
; some code about moving right could go here.
	inc xpos
	JMP OuterLoop

terminate:
; An INT call exists to print a string (about the Chonker being terminated).
	XOR SI, SI
	MOV DI, 9A0h
	MOV DX, @data
	MOV DS, DX
	MOV CX, nSize
	MOV SI, OFFSET msg
	MOV DX, 0B800h
	MOV ES, DX
		
msgLoop:
	MOV AL, byte ptr [SI]
	MOV AH, 80h + 4
	MOV ES: [DI], AX 
	INC DI
	INC SI
	INC DI
	LOOP msgloop

; exit the program.
	MOV AX, 4C00h
	INT 21h
_main ENDP
END _main

