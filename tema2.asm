; Teodor-Adrian Mirea, 323CA

extern puts
extern printf
extern strlen
extern strstr

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

; void xor_function(char *encoded_string, char *key);
;
; The function is used for the tasks 1 and 3. It does the xor operation between
; the *encoded_string* and *key* string pointers given as parameters.
xor_function:
		push	ebp
		mov	ebp, esp

		mov	edi, [ebp + 8]
		mov	esi, [ebp + 12]

xor_operation:
		mov	al, byte [edi]
		cmp	al, 0x0
		je	end_xor_function
		mov	ah, byte [esi]
		xor	al, ah
		mov	byte [edi], al
		inc	edi
		inc	esi
		jmp	xor_operation

end_xor_function:
		leave
		ret

; char hex_to_binary(char[2] hex_bytes);
;
; The function receives 2 bytes of type char representing two nibbles and
; converts them into one byte with the corresponding value. The function is
; used for solving the 2nd task. The resulted value is returned.
hex_to_binary:
		push	ebp
		mov	ebp, esp

		mov	ax, word [ebp + 8]

; Checking if the character is between 0-9 or a-f and transforming it in the
; corresponding value.
		cmp	ah, 0x61
		jl	convert_ah_0_9
		sub	ah, 0x61
		add	ah, 0xa
		jmp	continue_conversion

convert_ah_0_9:
		sub	ah, 0x30

continue_conversion:
; Checking if the character is between 0-9 or a-f and transforming it in the
; corresponding value.
		cmp	al, 0x61
		jl	convert_al_0_9
		sub	al, 0x61
		add	al, 0xa
		jmp	finish_conversion

convert_al_0_9:
		sub	al, 0x30

; Since the sistem is a little endian one, the most important part of the value
; is stored at the tail, so *al* should represent the higher part.
finish_conversion:
		shl	al, 4
		add	al, ah
		xor	ah, ah

		leave
		ret

; char base32_to_binary(char[2] base32_bytes);
;
; This function converts a char from the base32 alphabet into the corresponding
; binary value which is returned.
base32_to_binary:
		push	ebp
		mov	ebp, esp

		mov	ax, [ebp + 8]

; Checking if the character is between 2-9 or A-Z and transforming it in the
; corresponding value.
		cmp	ax, 0x41
		jl	base32_number
		sub	ax, 0x41
		jmp	finish_base32_to_binary

base32_number:
		sub	ax, 24

finish_base32_to_binary:
		leave
		ret

; TASK 1 -> void xor_strings(char *encoded_string, char *key);
;
; The function just calls the *xor_function* function implemented earlier with
; the two string pointers given as parameters.
xor_strings:
		push	ebp
		mov	ebp, esp

		mov	edi, [ebp + 8]
		mov	esi, [ebp + 12]

		push	esi
		push	edi
		call	xor_function
		add	esp, 8

		leave
		ret

; TASK 2 -> void rolling_xor(char *encoded_string);
;
; The function executes the decoding of a string encoded with the rolling_xor
; technique.
rolling_xor:
		push	ebp
		mov	ebp, esp

		mov	edi, [ebp + 8]
		mov	esi, edi

		push	edi
		call	strlen
		pop	edi

; The decoding operation starts from the end of the string.
		dec	eax
		add	edi, eax

rolling_xor_operation:
		mov	al, byte [edi]
		dec	edi
; If the operation intents to process the first byte, it should stop, because
; this byte was not changed during the encrypting process.
		cmp	edi, esi
		jl	finish_rolling_xor
		mov	ah, byte [edi]
		xor	al, ah
		mov	byte [edi + 1], al
		jmp	rolling_xor_operation

finish_rolling_xor:
		leave
		ret

; TASK 3 -> void xor_hex_string(char *encoded_string, char *key);
;
; The function transforms each two nibbles stored in two bytes in the strings
; given as parameter into only one corresponding byte and then does the
; xor operation by calling *xor_function*.
xor_hex_strings:
		push	ebp
		mov	ebp, esp

		mov	edi, [ebp + 8]
		mov	esi, [ebp + 12]
		mov	ecx, edi
		mov	edx, esi

; The string is parsed using *edi* while the corresponding values are places
; using *ecx* as iterator through the same string.
convert_string:
		mov	al, byte [edi]
		cmp	al, 0x0
		je	convert_key
		inc	edi
		mov	ah, byte [edi]
		inc	edi

		push	ax
		call	hex_to_binary
		add	esp, 2

		mov	byte [ecx], al
		inc	ecx
		jmp	convert_string

; The string is parsed using *esi* while the corresponding values are places
; using *edx* as iterator through the same string.
convert_key:
		mov	byte [ecx], 0x0

		mov	al, byte [esi]
		cmp	al, 0x0
		je	start_xor
		inc	esi
		mov	ah, byte [esi]
		inc	esi

		push	ax
		call	hex_to_binary
		add	esp, 2

		mov	byte [edx], al
		inc	edx
		jmp	convert_key

start_xor:
		mov	byte [edx], 0x0

		mov	edi, [ebp + 8]
		mov	esi, [ebp + 12]

		push	esi
		push	edi
		call	xor_function
		add	esp, 8

finish_xor_hex_strings:
		leave
		ret

; TASK 4 -> void base32decode(char *encoded_string);
;
; The function processes 2 or 3 bytes from the string given as parameter for
; creating the byte those encrypted bytes are 'hiding'. 
base32decode:
		push	ebp
		mov	ebp, esp

		mov	edi, [ebp + 8]
		mov	esi, edi

		xor	eax, eax
		xor	ebx, ebx
		xor	ecx, ecx
		xor	edx, edx
; The following code solves the decrypting process for blocks of 40 bits size.
decode:
; Finding the first character by processing the first two bytes (5 bits from
; the first byte and 3 from the second).
		mov	bl, byte [esi]
		cmp	bl, 0x0
		je	finish_base32decode
		push	bx
		call	base32_to_binary
		add	esp, 2
		mov	bx, ax
		shl	bl, 3

		inc	esi
		mov	cl, byte [esi]
		push	cx
		call	base32_to_binary
		add	esp, 2
		mov	cx, ax
		shr	cl, 2

; Creating the first character from the original 40 bits block.
		add	bl, cl
		mov	byte [edi], bl
		inc	edi

; Finding the second character by processing the second, third and fourth bytes
; (2 bits from the second byte, 5 from the third and 1 from the fourth).
		mov	bl, byte [esi]
		push	bx
		call	base32_to_binary
		add	esp, 2
		mov	bx, ax
		shl	bl, 6

		inc	esi
		mov	cl, byte [esi]
; Here the padding character may occur, so the conversion should stop.
		cmp	cl, 0x3d
		je	finish_base32decode
		push	cx
		call	base32_to_binary
		add	esp, 2
		mov	cx, ax
		shl	cl, 1

		inc	esi
		mov	dl, byte [esi]
		push	dx
		call	base32_to_binary
		add	esp, 2
		mov	dx, ax
		shr	dl, 4

; Creating the second character from the original 40 bits block.
		add	bl, cl
		add	bl, dl
		mov	byte [edi], bl
		inc	edi

; Finding the third character by processing the fourth and fifth bytes (4 bits
; from the fourth byte and 4 from the fifth).
		mov	bl, byte [esi]
		push	bx
		call	base32_to_binary
		add	esp, 2
		mov	bx, ax
		shl	bl, 4

		inc	esi
		mov	cl, byte [esi]
; Here the padding character may occur, so the conversion should stop.
		cmp	cl, 0x3d
		je	finish_base32decode
		push	cx
		call	base32_to_binary
		add	esp, 2
		mov	cx, ax
		shr	cl, 1

; Creating the third character from the original 40 bits block.
		add	bl, cl
		mov	byte [edi], bl
		inc	edi

; Finding the fourth character by processing the fifth, sixth and seventh bytes
; (1 bit from the fifth byte, 5 from the sixth and 2 from the seventh).
		mov	bl, byte [esi]
		push	bx
		call	base32_to_binary
		add	esp, 2
		mov	bx, ax
		shl	bl, 7

		inc	esi
		mov	cl, byte [esi]
; Here the padding character may occur, so the conversion should stop.
		cmp	cl, 0x3d
		je	finish_base32decode
		push	cx
		call	base32_to_binary
		add	esp, 2
		mov	cx, ax
		shl	cl, 2

		inc	esi
		mov	dl, byte [esi]
		push	dx
		call	base32_to_binary
		add	esp, 2
		mov	dx, ax
		shr	dx, 3

; Creating the fourth character from the original 40 bits block.
		add	bl, cl
		add	bl, dl
		mov	byte [edi], bl
		inc	edi

; Finding the fifth character by processing the seventh and eighth bytes (3
; bits from the seventh byte and 5 from the eighth).
		mov	bl, byte [esi]
		push	bx
		call	base32_to_binary
		add	esp, 2
		mov	bx, ax
		shl	bl, 5

		inc	esi
		mov	cl, byte [esi]
; Here the padding character may occur, so the conversion should stop.
		cmp	cl, 0x3d
		je	finish_base32decode
		push	cx
		call	base32_to_binary
		add	esp, 2
		mov	cx, ax

; Creating the fifth character from the original 40 bits block.
		add	bl, cl
		mov	byte [edi], bl
		inc	edi

		inc	esi
		jmp	decode

finish_base32decode:
		mov	byte [edi], 0x0
		leave 
		ret

; TASK 5 -> int bruteforce_singlebyte_xor(char *encoded_string);
;
; The function does brute force decrypting using all the ASCII characters until
; the decrypted string contains the word "force".
bruteforce_singlebyte_xor:
		push	ebp
		mov	ebp, esp

		sub	esp, 6
		mov	byte [esp], 'f'
		mov	byte [esp + 1], 'o'
		mov	byte [esp + 2], 'r'
		mov	byte [esp + 3], 'c'
		mov	byte [esp + 4], 'e'
		mov	byte [esp + 5], 0

		mov	edi, [ebp + 8]
		mov	esi, esp
		xor	ebx, ebx

; Taking every value between 0 and 255 and decrypting the string with xor
; operation. After every decrypting, the string is verified if it contains the
; "force" string.
bruteforce:
		cmp	byte [edi], 0x0
		je	check_bruteforce
		mov	al, byte [edi]
		xor	al, bl
		mov	byte [edi], al
		inc	edi
		jmp	bruteforce

check_bruteforce:
		mov	edi, [ebp + 8]
; Checking if the string contains the "force" string.
		push	esi
		push	edi
		call	strstr
		pop	edi
		pop	esi

		cmp	eax, 0x0
		jne	finish_bruteforce_singlebyte_xor

		mov	edi, [ebp + 8]

; If the string does not contain the "force" string, it is restored to the
; initial form in order to perform another xor operation.
restore_string:
		cmp	byte [edi], 0x0
		je	continue_bruteforce
		mov	al, byte [edi]
		xor	al, bl
		mov	byte [edi], al
		inc	edi
		jmp	restore_string

continue_bruteforce:
		inc bl
		cmp bl, 0
		je finish_bruteforce_singlebyte_xor
		mov	edi, [ebp + 8]
		jmp	bruteforce

finish_bruteforce_singlebyte_xor:
		mov	eax, ebx
		leave
		ret

; TASK 6 -> void decode_vigenere(char *encoded_string, char *key);
;
; The function decrypts every letter in the *encoded_string* by using the key.
decode_vigenere:
		push	ebp
		mov	ebp, esp

		mov	edi, [ebp + 8]
		mov	esi, [ebp + 12]

start_decode_vigenere:
		mov	al, byte [edi]
		cmp	al, 0
		je	finish_decode_vigenere

; Checking is the character is a letter or not.
		cmp	al, 0x61
		jl	non_alphabetic_character
		cmp	al, 0x7a
		jg	non_alphabetic_character
; If the character is a letter, the offset key corresponding value is
; substracted from the encrypted string character.
		mov	bl, byte [esi]
		sub	bl, 0x61
		sub	al, bl
; If the character is "out of bounds", it is placed back between a and z.
		cmp	al, 0x61
		jge	continue_decode_vigenere
		add	al, 0x1a

continue_decode_vigenere:
		mov	byte [edi], al
		inc	edi
		inc	esi
		cmp	byte [esi], 0
		jne	start_decode_vigenere
		mov	esi, [ebp + 12]
		jmp	start_decode_vigenere

non_alphabetic_character:
		inc	edi
		jmp	start_decode_vigenere

finish_decode_vigenere:
		leave
		ret

main:
		push	ebp
		mov	ebp, esp
		sub	esp, 2300

; test argc
		mov	eax, [ebp + 8]
		cmp	eax, 2
		jne	exit_bad_arg

; get task no
		mov	ebx, [ebp + 12]
		mov	eax, [ebx + 4]
		xor	ebx, ebx
		mov	bl, [eax]
		sub	ebx, '0'
		push	ebx

; verify if task no is in range
		cmp	ebx, 1
		jb	exit_bad_arg
		cmp	ebx, 6
		ja	exit_bad_arg

; create the filename
		lea	ecx, [filename + 7]
		add	bl, '0'
		mov	byte [ecx], bl

; fd = open("./input{i}.dat", O_RDONLY):
		mov	eax, 5
		mov	ebx, filename
		xor	ecx, ecx
		xor	edx, edx
		int	0x80
		cmp	eax, 0
		jl	exit_no_input

; read(fd, ebp - 2300, inputlen):
		mov	ebx, eax
		mov	eax, 3
		lea	ecx, [ebp-2300]
		mov	edx, [inputlen]
		int	0x80
		cmp	eax, 0
		jl	exit_cannot_read

; close(fd):
		mov	eax, 6
		int	0x80

; all input{i}.dat contents are now in ecx (address on stack)
		pop	eax
		cmp	eax, 1
		je	task1
		cmp	eax, 2
		je	task2
		cmp	eax, 3
		je	task3
		cmp	eax, 4
		je	task4
		cmp	eax, 5
		je	task5
		cmp	eax, 6
		je	task6
		jmp	task_done

task1:
; Finding the address of the key.
		xor	eax, eax
		push	ecx
		call	strlen
		pop	ecx

		add	eax, ecx
		inc	eax

; eax = key address, ecx = string address
		push	eax
		push	ecx
		call	xor_strings
		add	esp, 8

; Print resulting string.
		push	ecx
		call	puts
		add	esp, 4

		jmp	task_done

task2:
; ecx = string address
		push	ecx
		call	rolling_xor
		pop	ecx

; Print resulting string.
		push	ecx
		call	puts
		add	esp, 4

		jmp	task_done

task3:
; Finding the address of the key.
		xor	edx, edx
		push	ecx
		call	strlen
		pop	ecx

		add	eax, ecx
		inc	eax

; eax = key address, ecx = string address
		push	eax
		push	ecx
		call	xor_hex_strings
		pop	ecx
		add	esp, 4

; Print resulting string.
		push	ecx
		call	puts
		add	esp, 8

		jmp	task_done

task4:
; ecx = string address
		push	ecx
		call	base32decode
		pop	ecx

; Print resulting string.
		push	ecx
		call	puts
		pop	ecx

		jmp	task_done

task5:
; ecx = string address
		push	ecx
		call	bruteforce_singlebyte_xor
		pop	ecx

; eax = key value
		push	eax

; Print resulting string.
		push	ecx
		call	puts
		pop	ecx

; Print the key value.
		pop	eax
		push	eax
		push	fmtstr
		call	printf
		add	esp, 8

		jmp	task_done

task6:
; Finding the key address.
		xor	eax, eax
		push	ecx
		call	strlen
		pop	ecx

		add	eax, ecx
		inc	eax

; eax = key address, ecx = string address
		push	eax
		push	ecx 
		call	decode_vigenere
		pop	ecx
		add	esp, 4

; Print resulting string
		push	ecx
		call	puts
		add	esp, 4

task_done:
		xor	eax, eax
		jmp	exit

exit_bad_arg:
		mov	ebx, [ebp + 12]
		mov	ecx , [ebx]
		push	ecx
		push	usage
		call	printf
		add	esp, 8
		jmp	exit

exit_no_input:
		push	filename
		push	error_no_file
		call	printf
		add	esp, 8
		jmp	exit

exit_cannot_read:
		push	filename
		push	error_cannot_read
		call	printf
		add	esp, 8
		jmp	exit

exit:
		mov	esp, ebp
		pop	ebp
		ret
