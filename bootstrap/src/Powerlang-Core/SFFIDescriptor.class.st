Class {
	#name : #SFFIDescriptor,
	#superclass : #ByteArray,
	#type : #bytes,
	#classVars : [
		'FFICallingConventions',
		'FFITypes'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'class initialization' }
SFFIDescriptor class >> initialize [
	self initializeFFITypes; initializeCallingConventions
]

{ #category : #'class initialization' }
SFFIDescriptor class >> initializeCallingConventions [
	FFICallingConventions := Dictionary new.
	FFICallingConventions
		at: 'cdecl' put: 20;
		at: 'com' put: 21;
		at: 'callback' put: 22
]

{ #category : #'class initialization' }
SFFIDescriptor class >> initializeFFITypes [
	FFITypes := Dictionary new.
	FFITypes
		at: 'char' put: 1;
		at: 'uchar' put: 2;
		at: 'short' put: 3;
		at: 'ushort' put: 4;
		at: 'long' put: 5;
		at: 'ulong' put: 6;
		at: 'large' put: 7;
		at: 'ularge' put: 8;
		at: 'intptr' put: 9;
		at: 'uintptr' put: 10;
		at: 'pointer' put: 11;
		at: 'struct' put: 12;
		at: 'float' put: 13;
		at: 'double' put: 14
]

{ #category : #'as yet unclassified' }
SFFIDescriptor class >> ret: aString args: aCollection cc: ccName [
	| args return cc result |
	args := aCollection
		collect: [ :argname | 
			FFITypes
				at: argname asString
				ifAbsent: [ self error: 'undefined argument type ' , argname ] ].
	return := FFITypes
		at: aString
		ifAbsent: [ self error: 'undefined result type ' , aString ].
	cc := FFICallingConventions
		at: ccName
		ifAbsent: [ self error: 'unsupported calling convention ' , ccName ].
	result := self new: args size + 2.
	^ result
		callingConvention: cc;
		return: return;
		arguments: args
]

{ #category : #calls }
SFFIDescriptor >> arguments: aCollection [
	self replaceFrom: 3 to: 3 + aCollection size -1 with: aCollection
]

{ #category : #calls }
SFFIDescriptor >> callingConvention: anInteger [
	self at: 1 put: anInteger
]

{ #category : #calls }
SFFIDescriptor >> return: anInteger [
	self at: 2 put: anInteger
]
