Class {
	#name : #SysVX64ABI,
	#superclass : #X64ABI,
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'as yet unclassified' }
SysVX64ABI >> emitEntrypoint: anFFIDescriptor with: anAssembler [
	anAssembler saveCallerFrame;
			pushG;
		pushNil;
		pushTrue;
		pushFalse;
		pushM.
	self storeArgumentsInStack: anFFIDescriptor with: anAssembler.
	
]

{ #category : #'as yet unclassified' }
SysVX64ABI >> popRetaddrAndArgs: anFFIDescriptor with: anAssembler [
	anAssembler
		popA;
		popA;
		popA
]

{ #category : #'as yet unclassified' }
SysVX64ABI >> restoreContext: anFFIDescriptor with: anAssembler [
	self popRetaddrAndArgs: anFFIDescriptor with: anAssembler.
	anAssembler
		popM;
		popFalse;
		popTrue;
		popNil;
		popG;
		popFP;
		return
]

{ #category : #'as yet unclassified' }
SysVX64ABI >> storeArgumentsInStack: anFFIDescriptor with: anAssembler [

	anAssembler pushS;
		loadRwithArgPointer;
		convertRtoSmallInteger;
		pushR
]
