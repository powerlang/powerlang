Class {
	#name : #NativizationTarget,
	#superclass : #Object,
	#instVars : [
		'name',
		'wordSize',
		'abi',
		'codeGeneratorClass'
	],
	#classVars : [
		'Default'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
NativizationTarget class >> default [
	"Return the default target to use for tests. Defaults to host.

	 NEVER, EVER use this for anything but testing!"

	^ Default notNil ifTrue: [ Default ] ifFalse: [ self host ]
]

{ #category : #accessing }
NativizationTarget class >> default: aNativizationTarget [
	"Set the default target to use in tests."

	Default := aNativizationTarget.
]

{ #category : #accessing }
NativizationTarget class >> host [
	"Return target for the machine this code is running on."

	| host |

	host := Smalltalk host.
	host = 'x86_64-linux-gnu' ifTrue:[ ^ self x86_64_linux_gnu ].
	host = 'x86_64-darwin' ifTrue:[ ^ self x86_64_darwin ].
	host = 'x86_64-win32' ifTrue:[ ^self x86_64_win32 ].

	host = 'riscv64-linux-gnu' ifTrue:[ ^ self riscv64_linux_gnu ].

	self error:'Unssuported host: ', host.
]

{ #category : #'instance creation' }
NativizationTarget class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #accessing }
NativizationTarget class >> x86_64_darwin [
	^ self new
		name: 'x86_64-darwin';
		wordSize: 8;
		abi: SysVX64ABI new;
		codeGeneratorClass: AssemblerAMD64;
		yourself
]

{ #category : #accessing }
NativizationTarget class >> x86_64_linux_gnu [
	^ self new
		name: 'x86_64-linux-gnu';
		wordSize: 8;
		abi: SysVX64ABI new;
		codeGeneratorClass: AssemblerAMD64;   
		yourself
]

{ #category : #accessing }
NativizationTarget class >> x86_64_win32 [
	^ self new
		name: 'x86_64-win32';
		wordSize: 8;
		abi: WinX64ABI new;
		codeGeneratorClass: AssemblerAMD64;   
		yourself
]

{ #category : #accessing }
NativizationTarget >> abi [
	self ASSERT: abi notNil.  
	^ abi
]

{ #category : #initialization }
NativizationTarget >> abi:anABI [
	self ASSERT: abi isNil.
	self ASSERT: anABI notNil.

	abi := anABI.
]

{ #category : #initialization }
NativizationTarget >> codeGeneratorClass: aClass [
	self ASSERT: codeGeneratorClass isNil.
	self ASSERT: aClass notNil.

	codeGeneratorClass := aClass.
]

{ #category : #initialization }
NativizationTarget >> initialize [
	"super initialize.   -- commented since inherited method does nothing"
]

{ #category : #accessing }
NativizationTarget >> name [
	self ASSERT: name notNil.
	^ name
]

{ #category : #initialization }
NativizationTarget >> name: aString [
	self ASSERT: name isNil.
	self ASSERT: aString notNil.

	name := aString.
]

{ #category : #'instance creation' }
NativizationTarget >> newCodeGenerator [
	self ASSERT: codeGeneratorClass notNil.

	^ codeGeneratorClass forTarget: self.
]

{ #category : #'instance creation' }
NativizationTarget >> newNativizer [
	^ Nativizer forTarget: self
]

{ #category : #'printing & storing' }
NativizationTarget >> printOn:aStream [
	super printOn:aStream.
	aStream nextPut: $(.
	name printOn:aStream.
	aStream nextPut: $).
]

{ #category : #accessing }
NativizationTarget >> wordSize [
	self ASSERT: wordSize notNil.
	^ wordSize
]

{ #category : #initialization }
NativizationTarget >> wordSize:anInteger [
	self ASSERT: wordSize isNil.
	self ASSERT:(anInteger == 8 or:[ anInteger == 4]).

	wordSize := anInteger.
]

{ #category : #accessing }
NativizationTarget >> wordSizeShift [
	^ #(0 0 0 2 0 0 0 3) at: self wordSize
]
