Class {
	#name : #WinX64ABI,
	#superclass : #X64ABI,
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #services }
WinX64ABI >> restoreContextUsing: anAssembler popping: anInteger [
	anAssembler
		popA;
		popA;
		popB;
		popE;
		popS;
		popFalse;
		popTrue;
		popNil;
		popG;
		popFP;
		return
]

{ #category : #services }
WinX64ABI >> saveContextUsing: anAssembler [
	anAssembler
		saveCallerFrame;
		storeArgumentsInStack;
		pushG;
		pushNil;
		pushFalse;
		pushTrue;
		pushS;
		pushE;
		pushB;
		loadRwithArgPointer;
		convertRtoSmallInteger;
		pushR
]
