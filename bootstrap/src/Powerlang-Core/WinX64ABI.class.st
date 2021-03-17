Class {
	#name : #WinX64ABI,
	#superclass : #X64ABI,
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #services }
WinX64ABI >> emitEntrypoint: anFFIDescriptor with: anAssembler [
	anAssembler saveCallerFrame;
		pushG;
		pushNil;
		pushTrue;
		pushFalse;
		pushM;
		pushE;
		pushS.
	self storeArgumentsInStack: anFFIDescriptor with: anAssembler.
	
]

{ #category : #services }
WinX64ABI >> popRetaddrAndArgs: anFFIDescriptor with: anAssembler [
	anAssembler
		popA;
		popA;
		popA
]

{ #category : #services }
WinX64ABI >> restoreContext: anFFIDescriptor with: anAssembler [
	self popRetaddrAndArgs: anFFIDescriptor with: anAssembler.
	anAssembler
		popS;
		popE;
		popM;
		popFalse;
		popTrue;
		popNil;
		popG;
		popFP;
		return
]

{ #category : #services }
WinX64ABI >> storeArgumentsInStack: anFFIDescriptor with: anAssembler [
	anAssembler pushS;
		loadRwithArgPointer;
		convertRtoSmallInteger;
		pushR
]
