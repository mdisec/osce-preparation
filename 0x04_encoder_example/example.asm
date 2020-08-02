section .data
text: db '0XAZEROT' ; Programi buyuk harflerde yada ascii'den tasmayacak sekilde karakterler ile deneyin, kucuk 'z' karakterinin ascii tabloda 5 ve 10 fazlasi tablo disina cikiyor. Ayriyeten kontrol mekanizmalari eklemeye erindim :)  
len equ $ - text

section .text
global _start

_start:
	push ebp ; func prologue
	mov ebp,esp ; func prologue
	mov ecx,text ; stringin bellek adresini ecx registirina yaz	
	mov dl,len ; stringin uzunlugunu edx registerinin low kismina yaz
	push ecx ; loc_encoder fonksiyonu 1.parametre = string bellek adresi
	push edx ; loc_encoder fonksyionu 2.parametre = string uzunlugu -- push dl seklinde calismaz
	call loc_encoder ; function cagrisi
	mov ecx,eax ; ecx registerina sifrelenmis stringin memorydeki adresini koy. sys_write sistem cagrisi yazdirilacak stringin adresini ecx'ten okur
 	mov edx,[esp] ; edx degeri fonksiyondan ciktiktan sonra degistigi icin tekrar uzunlugu al, mov edx,len seklindede alinabilir.
	mov eax,0x3 ; sifreleme sonucunda, verilen stringin uzunlugu 3 katına cikacak. Yazdirma islemi yaparken edx registerina stringin uzunlugunu vermemiz gerektigi icin uzunlugu hesapliyoruz.
	mul edx ; string uzunluğunu 3 ile çarp ve sonucu eax registerina yaz.
	mov edx,eax ; edx registerina sifreli stringin uzunlugu yazildi, sys_write sistem cagrisi yazdirilacak stringin adresini edx'ten okur
	mov eax,4 ; sys_write sistem cagrisi yapiyoruz ecx:edx registerlarini kullaniyor. 
	mov ebx,1 ; file descriptor (stdout)
	int 0x80 ; kernel cagrisi 	
	pop edi ; bellege pushlanan parametreleri pop et
	pop edi ; bellege pushlanan parametreleri pop et
	mov esp,ebp ; func epilogue
	pop ebp ; func epilogue
	mov eax,1 ; sys_exit program sonlandirma cagrisi
	mov ebx,0 ; cikis kodu (exit status)
	int 0x80 ; kernel cagrisi
	
loc_encoder: ;func label
	push ebp ;func prologue
	mov ebp,esp ; func prologue
	mov esi,[esp+0x8] ; yollanan parametrelerden string uzunlugunu ESI registirina yaz  
	mov edi,[esp+0xc] ; yollanan parametrelerden sifrelenecek stringin bellek adresini EDI registerina yaz
	xor ecx,ecx ;i=0 ; sifrele dongusunde kullanilacak sayac. Amaci orjinal stringin onune iki tane sifreli karakter koymak.
	xor ebx,ebx ;j=0 ; while dongusunde kullanilacak sayac. Dongu icinde 'str[i]' gibi indis gorevi gorur
	sub esp,0x64 ; sifreli metin icin bellekte 100 byte yer ayir (100 karakterlik 1byte=1char)
	jmp while_comp ; while dongusu icin comparison adresine zipla
	while: ; bu dongu sifrelencek string uzunlugu kadar doner
	mov dl,[edi+ebx] ; ebx arttikca stringin bir sonraki karakterini dl registirina atar 	
	jmp sif_comp ; sifrele dongusunun comparison adresine zipla
	sifrele: ; bu dongu her karakterin ascii tabloda once kendisini sonra 5 ve 10 karakter ilerisindeki degeri bellekte ayrilan alana yazar orn:(ABC stringini [A]FK[B]GL[C]HM seklinde sifreler). Dongu toplamda 2 kere donmektedir. 
		mov eax,ebx ; eax registirina stringin hangi indis'inde oldugunu yaz. Asagidaki mov [esp+eax],dl bolumunde sifreli stringi olustururken isimize yarayacak. O yuzden once mov [esp+eax],dl bolumunu oku  
		mov dh,3 ; adres hesaplamadaki ebx*3 kismini ayarliyoruz
		mul dh ; eax registerinda bulunan indis degeri ile dh degistirini carp eax'a yaz
		add eax,ecx ; adres hesaplama icin ebx*3 + ecx kismini ayarliyoruz. 
		mov [esp+eax],dl ; esp sifreli stringin baslangic adresini tutuyor. eax=ebx*3+ecx degerini tasiyor. Yani sifrelenecek string ABC ise ebx=0 iken A karakteri seciliyor, dongu icinde ecx sirasiyla 0,1,2 degerlerini alacak ve [esp + 0*3 + 0], [esp + 0*3 + 1], [esp + 0*3 + 2] seklinde sirasiyla karakterlerin yazilacagi adresi belirlemis oluruz. ebx=0 icin AFK sifreli metnini yazar. ebx=1 icin BGL. Bu islemi register üzerinden yapmamizin sebebi mov [esp+ebx*3+ecx],dl seklinde yazinca calismamaktadir.  	
		add dl,0x5 ; sifreleme icin mevcuttaki karakterin ascii tablosuna göre 5 karakter ilerisinde ki degeri alir ve dl registerina yazar. Bu islemi 2 defa yapacagi icin orn: A icin F ve K  
		inc ecx ; dongu sayacini 1 arttir
		sif_comp: ; sifrele dongusunun comparison islemi burada yapilir
			cmp ecx,3 ; 3 ile ecx'i karsilastir
			jl sifrele ; ecx 3'ten kucukse tekrar sifrele'ye zipla 
			inc ebx ; while dongu sayacini 1 arttir
		while_comp: ; while dongusunun comparison islemi burada yapilir 
			xor ecx,ecx ; sifrele dongusunden ciktiktan sonra sayaci sifirlar	
			cmp ebx,esi ; esi=string uzunlugu ile ebx'i karsilastir 
			jl while ; ebx string uzunlugundan kucukse while dongusune zipla
	lea eax,[esp] ; eax registerina sifrelenmis stringin baslangic adresini yaz
	mov esp,ebp ; func epilogue
	pop ebp ; func epilogue
	ret ; donus adresini stackten pop eder epi register degerini gunceller, eax'in degerini _start fonksiyonuna dondur 
