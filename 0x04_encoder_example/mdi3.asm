
; nasm -f elf32 mdi3.asm 
; gcc -c mdi3c.c
; gcc -m32 -o mdi3 mdi3.o mdi3c.o
; ./mdi3

; section .data

section .text
global encoder

encoder:
	push ebp ;func prologue
	mov ebp,esp ; func prologue
	
	; eax = string adresi.
	mov esi, eax  ; lodsb işlemi için hazırlık yapıyorum. esi = eax = string adresi  
	mov edi, eax  ; string uzunluğunu bulmak için kullandığım prog. parcasındaki scasb instr. için edi kullanılır.
	
	; burada string uzunluğunu buluyoruz.
	xor	ecx, ecx  ; ecx = 0 ; alternatif1: sub ecx,ecx ,alternatif2: mov ecx, 0 
	not	ecx       ; ecx = 0xFFFFFFFF (max loop count) ; bu ve üstteki satırın alternatifi: mov ecx, 0xFFFFFFFF 
	xor	al, al    ; al = 0 ; null termination ile ilgili işlem yapacağız. ; alternatif1: sub al,al ,alternatif2: mov al,0
	cld           ; tüm string işlemleri(scas/lods/stos/movs) , ilgili index registerları(esi/edi) artırsın.    
    repne scasb   ; edi adresi ile işaret edilen byte, al(0)'ye eşit olmadığı sürece arama işlemini tekrarla (repne: repeat -while- not equal). 
	not	ecx       ; buraya eksilerek gelen ecx'in bütünleyeni şeklinde düşünebiliriz.
	dec	ecx       ; null termination hariç hesaplamak istiyoruz. 
    ; string uzunluğu bulundu. ecx = string uzunluğu.
	
	sub esp,0x64  ; @n0bl1nk sifreli metin icin bellekte 100 byte yer ayir (100 karakterlik 1byte=1char) @n0bl1nk
	mov edi,esp    
	
	cld    
loc_rpt1:
    lodsb   ; esi adresinin gösterdiği byte'ı al registerına koy (al = byte ptr [esi]). al ile işlem yapmak için bu ve bir alttaki satırı birleştirip movsb yazmayacağım; movsb al üzerinde değişiklik yapmaz.
    stosb   ; al registerındaki değeri edi adresinin gösterdiği byte'a koy. (byte ptr [edi] = al)
    add al,5    
    stosb   
    add al,5
    stosb
    loop loc_rpt1
    
	xor al,al  ; null termination için gerekli.
	stosb
	
	lea eax,[esp] ; donus degeri burada; yani oluşturduğumuz stringin başlangıcı. 

	mov esp,ebp ; func epilogue
	pop ebp ; func epilogue
	ret 
 
