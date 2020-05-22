Class {
	#name : #HaltingSend,
	#superclass : #MessageLinker,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #nativizing }
HaltingSend >> emitSend: aSymbol using: anAssembler [
	anAssembler breakpoint
]
