Class {
	#name : #SysVX64ABI,
	#superclass : #X64ABI,
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'as yet unclassified' }
SysVX64ABI >> emitEntrypoint: anFFIDescriptor with: anAssembler [
	anAssembler saveCallerFrame.
	self storeArgumentsInStack: anFFIDescriptor with: anAssembler.
	anAssembler
		pushG;
		pushNil;

		pushTrue;
		pushFalse;		pushM;
		loadRwithArgPointer;
		convertRtoSmallInteger;
		pushR
]

{ #category : #'as yet unclassified' }
SysVX64ABI >> restoreContextUsing: anAssembler popping: anInteger [
	anAssembler
		restoreCallerFrame;
		popA;
		popM;
		popFalse;
		popTrue;
		popNil;
		popG;
		restoreCallerFrame;
		return
]

{ #category : #'as yet unclassified' }
SysVX64ABI >> storeArgumentsInStack: anFFIDescriptor with: anAssembler [
	anAssembler
		pushS
]
