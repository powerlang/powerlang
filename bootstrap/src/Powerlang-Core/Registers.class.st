Class {
	#name : #Registers,
	#superclass : #SharedPool,
	#classVars : [
		'ah',
		'al',
		'ax',
		'bh',
		'bl',
		'bp',
		'bpl',
		'bx',
		'ch',
		'cl',
		'cs',
		'cx',
		'dh',
		'di',
		'dil',
		'dl',
		'ds',
		'dx',
		'eax',
		'ebp',
		'ebx',
		'ecx',
		'edi',
		'edx',
		'es',
		'esi',
		'esp',
		'fs',
		'gs',
		'mmx0',
		'mmx1',
		'mmx2',
		'mmx3',
		'mmx4',
		'mmx5',
		'mmx6',
		'mmx7',
		'r10',
		'r10b',
		'r10d',
		'r10w',
		'r11',
		'r11b',
		'r11d',
		'r11w',
		'r12',
		'r12b',
		'r12d',
		'r12w',
		'r13',
		'r13b',
		'r13d',
		'r13w',
		'r14',
		'r14b',
		'r14d',
		'r14w',
		'r15',
		'r15b',
		'r15d',
		'r15w',
		'r8',
		'r8b',
		'r8d',
		'r8w',
		'r9',
		'r9b',
		'r9d',
		'r9w',
		'rax',
		'rbp',
		'rbx',
		'rcx',
		'rdi',
		'rdx',
		'rip',
		'rsi',
		'rsp',
		'si',
		'sil',
		'sp',
		'spl',
		'ss',
		'xmm0',
		'xmm1',
		'xmm10',
		'xmm11',
		'xmm12',
		'xmm13',
		'xmm14',
		'xmm15',
		'xmm2',
		'xmm3',
		'xmm4',
		'xmm5',
		'xmm6',
		'xmm7',
		'xmm8',
		'xmm9',
		'ymm0',
		'ymm1',
		'ymm10',
		'ymm11',
		'ymm12',
		'ymm13',
		'ymm14',
		'ymm15',
		'ymm2',
		'ymm3',
		'ymm4',
		'ymm5',
		'ymm6',
		'ymm7',
		'ymm8',
		'ymm9'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'as yet unclassified' }
Registers class >> initialize [ 
dil := (Register new name: 'dil'; index: 7; length: 8; initializeFlags).
bh := (Register new name: 'bh'; index: 7; length: 8; initializeFlags).
bl := (Register new name: 'bl'; index: 3; length: 8; initializeFlags).
rbp := (Register new name: 'rbp'; index: 5; length: 64; initializeFlags).
ymm11 := (Register new name: 'ymm11'; index: 11; length: 256; initializeFlags).
si := (Register new name: 'si'; index: 6; length: 16; initializeFlags).
ymm10 := (Register new name: 'ymm10'; index: 10; length: 256; initializeFlags).
r11w := (Register new name: 'r11w'; index: 11; length: 16; initializeFlags).
ymm13 := (Register new name: 'ymm13'; index: 13; length: 256; initializeFlags).
ymm12 := (Register new name: 'ymm12'; index: 12; length: 256; initializeFlags).
rbx := (Register new name: 'rbx'; index: 3; length: 64; initializeFlags).
ymm15 := (Register new name: 'ymm15'; index: 15; length: 256; initializeFlags).
ymm14 := (Register new name: 'ymm14'; index: 14; length: 256; initializeFlags).
gs := (Register new name: 'gs'; index: 5; length: 16; initializeFlags).
r11b := (Register new name: 'r11b'; index: 11; length: 8; initializeFlags).
r11d := (Register new name: 'r11d'; index: 11; length: 32; initializeFlags).
edi := (Register new name: 'edi'; index: 7; length: 32; initializeFlags).
rip := (Register new name: 'rip'; index: 5; length: 64; initializeFlags).
r14w := (Register new name: 'r14w'; index: 14; length: 16; initializeFlags).
r12d := (Register new name: 'r12d'; index: 12; length: 32; initializeFlags).
edx := (Register new name: 'edx'; index: 2; length: 32; initializeFlags).
r12b := (Register new name: 'r12b'; index: 12; length: 8; initializeFlags).
r14b := (Register new name: 'r14b'; index: 14; length: 8; initializeFlags).
xmm10 := (Register new name: 'xmm10'; index: 10; length: 128; initializeFlags).
xmm11 := (Register new name: 'xmm11'; index: 11; length: 128; initializeFlags).
xmm12 := (Register new name: 'xmm12'; index: 12; length: 128; initializeFlags).
xmm13 := (Register new name: 'xmm13'; index: 13; length: 128; initializeFlags).
xmm14 := (Register new name: 'xmm14'; index: 14; length: 128; initializeFlags).
xmm15 := (Register new name: 'xmm15'; index: 15; length: 128; initializeFlags).
r14d := (Register new name: 'r14d'; index: 14; length: 32; initializeFlags).
rcx := (Register new name: 'rcx'; index: 1; length: 64; initializeFlags).
r12w := (Register new name: 'r12w'; index: 12; length: 16; initializeFlags).
ecx := (Register new name: 'ecx'; index: 1; length: 32; initializeFlags).
esp := (Register new name: 'esp'; index: 4; length: 32; initializeFlags).
r15d := (Register new name: 'r15d'; index: 15; length: 32; initializeFlags).
fs := (Register new name: 'fs'; index: 4; length: 16; initializeFlags).
r13b := (Register new name: 'r13b'; index: 13; length: 8; initializeFlags).
r13d := (Register new name: 'r13d'; index: 13; length: 32; initializeFlags).
r15b := (Register new name: 'r15b'; index: 15; length: 8; initializeFlags).
esi := (Register new name: 'esi'; index: 6; length: 32; initializeFlags).
r15w := (Register new name: 'r15w'; index: 15; length: 16; initializeFlags).
r8 := (Register new name: 'r8'; index: 8; length: 64; initializeFlags).
r9 := (Register new name: 'r9'; index: 9; length: 64; initializeFlags).
r13w := (Register new name: 'r13w'; index: 13; length: 16; initializeFlags).
bpl := (Register new name: 'bpl'; index: 5; length: 8; initializeFlags).
ebx := (Register new name: 'ebx'; index: 3; length: 32; initializeFlags).
ebp := (Register new name: 'ebp'; index: 5; length: 32; initializeFlags).
rsp := (Register new name: 'rsp'; index: 4; length: 64; initializeFlags).
ax := (Register new name: 'ax'; index: 0; length: 16; initializeFlags).
xmm0 := (Register new name: 'xmm0'; index: 0; length: 128; initializeFlags).
xmm1 := (Register new name: 'xmm1'; index: 1; length: 128; initializeFlags).
rsi := (Register new name: 'rsi'; index: 6; length: 64; initializeFlags).
xmm2 := (Register new name: 'xmm2'; index: 2; length: 128; initializeFlags).
spl := (Register new name: 'spl'; index: 4; length: 8; initializeFlags).
r10 := (Register new name: 'r10'; index: 10; length: 64; initializeFlags).
r11 := (Register new name: 'r11'; index: 11; length: 64; initializeFlags).
r12 := (Register new name: 'r12'; index: 12; length: 64; initializeFlags).
r13 := (Register new name: 'r13'; index: 13; length: 64; initializeFlags).
r14 := (Register new name: 'r14'; index: 14; length: 64; initializeFlags).
r15 := (Register new name: 'r15'; index: 15; length: 64; initializeFlags).
xmm3 := (Register new name: 'xmm3'; index: 3; length: 128; initializeFlags).
xmm4 := (Register new name: 'xmm4'; index: 4; length: 128; initializeFlags).
xmm5 := (Register new name: 'xmm5'; index: 5; length: 128; initializeFlags).
xmm6 := (Register new name: 'xmm6'; index: 6; length: 128; initializeFlags).
xmm7 := (Register new name: 'xmm7'; index: 7; length: 128; initializeFlags).
xmm8 := (Register new name: 'xmm8'; index: 8; length: 128; initializeFlags).
xmm9 := (Register new name: 'xmm9'; index: 9; length: 128; initializeFlags).
al := (Register new name: 'al'; index: 0; length: 8; initializeFlags).
r8w := (Register new name: 'r8w'; index: 8; length: 16; initializeFlags).
ah := (Register new name: 'ah'; index: 4; length: 8; initializeFlags).
r8d := (Register new name: 'r8d'; index: 8; length: 32; initializeFlags).
r8b := (Register new name: 'r8b'; index: 8; length: 8; initializeFlags).
rdx := (Register new name: 'rdx'; index: 2; length: 64; initializeFlags).
r9b := (Register new name: 'r9b'; index: 9; length: 8; initializeFlags).
es := (Register new name: 'es'; index: 0; length: 16; initializeFlags).
r9d := (Register new name: 'r9d'; index: 9; length: 32; initializeFlags).
mmx0 := (Register new name: 'mmx0'; index: 0; length: 64; initializeFlags).
ymm5 := (Register new name: 'ymm5'; index: 5; length: 256; initializeFlags).
ymm4 := (Register new name: 'ymm4'; index: 4; length: 256; initializeFlags).
ymm7 := (Register new name: 'ymm7'; index: 7; length: 256; initializeFlags).
ymm6 := (Register new name: 'ymm6'; index: 6; length: 256; initializeFlags).
mmx5 := (Register new name: 'mmx5'; index: 5; length: 64; initializeFlags).
mmx6 := (Register new name: 'mmx6'; index: 6; length: 64; initializeFlags).
mmx7 := (Register new name: 'mmx7'; index: 7; length: 64; initializeFlags).
ymm0 := (Register new name: 'ymm0'; index: 0; length: 256; initializeFlags).
ymm2 := (Register new name: 'ymm2'; index: 2; length: 256; initializeFlags).
ymm3 := (Register new name: 'ymm3'; index: 3; length: 256; initializeFlags).
rax := (Register new name: 'rax'; index: 0; length: 64; initializeFlags).
cl := (Register new name: 'cl'; index: 1; length: 8; initializeFlags).
ymm9 := (Register new name: 'ymm9'; index: 9; length: 256; initializeFlags).
ymm8 := (Register new name: 'ymm8'; index: 8; length: 256; initializeFlags).
ch := (Register new name: 'ch'; index: 5; length: 8; initializeFlags).
rdi := (Register new name: 'rdi'; index: 7; length: 64; initializeFlags).
r9w := (Register new name: 'r9w'; index: 9; length: 16; initializeFlags).
ymm1 := (Register new name: 'ymm1'; index: 1; length: 256; initializeFlags).
mmx1 := (Register new name: 'mmx1'; index: 1; length: 64; initializeFlags).
mmx2 := (Register new name: 'mmx2'; index: 2; length: 64; initializeFlags).
mmx3 := (Register new name: 'mmx3'; index: 3; length: 64; initializeFlags).
mmx4 := (Register new name: 'mmx4'; index: 4; length: 64; initializeFlags).
cs := (Register new name: 'cs'; index: 1; length: 16; initializeFlags).
r10d := (Register new name: 'r10d'; index: 10; length: 32; initializeFlags).
r10b := (Register new name: 'r10b'; index: 10; length: 8; initializeFlags).
cx := (Register new name: 'cx'; index: 1; length: 16; initializeFlags).
r10w := (Register new name: 'r10w'; index: 10; length: 16; initializeFlags).
dl := (Register new name: 'dl'; index: 2; length: 8; initializeFlags).
dh := (Register new name: 'dh'; index: 6; length: 8; initializeFlags).
di := (Register new name: 'di'; index: 7; length: 16; initializeFlags).
ds := (Register new name: 'ds'; index: 3; length: 16; initializeFlags).
eax := (Register new name: 'eax'; index: 0; length: 32; initializeFlags).
sil := (Register new name: 'sil'; index: 6; length: 8; initializeFlags).
dx := (Register new name: 'dx'; index: 2; length: 16; initializeFlags).
bx := (Register new name: 'bx'; index: 3; length: 16; initializeFlags).
sp := (Register new name: 'sp'; index: 4; length: 16; initializeFlags).
ss := (Register new name: 'ss'; index: 2; length: 16; initializeFlags).
bp := (Register new name: 'bp'; index: 5; length: 16; initializeFlags).

]
