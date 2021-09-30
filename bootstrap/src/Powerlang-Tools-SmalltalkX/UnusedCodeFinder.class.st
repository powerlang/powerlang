Class {
	#name : #UnusedCodeFinder,
	#superclass : #Object,
	#instVars : [
		'allClasses',
		'knownUsedSelectors',
		'unusedMethods'
	],
	#category : #'Powerlang-Tools-SmalltalkX'
}

{ #category : #documentation }
UnusedCodeFinder class >> documentation [
"
	Usage:

		UnusedCodeFinder new
			search;
			browse

		UnusedCodeFinder new
			search;
			reportTo: '~/Downloads/unused.txt'
		

	[author:]
		Jan Vrany <jan.vrany@labware.com>

	[instance variables:]

	[class variables:]

	[see also:]

"

]

{ #category : #'instance creation' }
UnusedCodeFinder class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #utilities }
UnusedCodeFinder >> browse [
	unusedMethods isEmptyOrNil ifTrue: [ self search ].
	NewSystemBrowser browseMethods: unusedMethods

]

{ #category : #queries }
UnusedCodeFinder >> checkIfUsed: aMethod [
	| senders |

	(knownUsedSelectors includes: aMethod selector) ifTrue: [
		^ true
	].

	senders := SystemBrowser findSendersOf: aMethod selector in: allClasses ignoreCase: false.
	senders := senders reject: [:method | unusedMethods includes: method ].

	^ senders notEmpty

]

{ #category : #initialization }
UnusedCodeFinder >> initialize [
	allClasses := #(#'Powerlang-Core') gather: [ :p | ProjectDefinition searchForClassesWithProject: p ].
	knownUsedSelectors := allClasses gather: [ :c | c performedSelectors ].

]

{ #category : #utilities }
UnusedCodeFinder >> reportOn: s [
	| unusedMethodsByClass |

	unusedMethodsByClass := self unusedMethodsByClass.

	s nextPutLine: '{'.
	(unusedMethodsByClass keys sorted: [ :a :b | a name < b name ]) do: [:cls |
		s nextPutAll: cls name.
		s nextPutLine: ' -> {'.
		(unusedMethodsByClass at: cls) do: [:mth | 
			s tab; tab.
			s nextPutAll: cls name.
			s nextPutAll: ' >> '.
			s nextPutAll: mth selector storeString.
			s nextPutLine: '.'.
		].
		s nextPutLine: '}.'.
	].
	s nextPutLine: '{'.

]

{ #category : #utilities }
UnusedCodeFinder >> reportTo: path [
	path asFilename writingFileDo: [ :s|
		self reportOn: s
	].

]

{ #category : #searching }
UnusedCodeFinder >> search [
	| searchedClasses |

	unusedMethods := Set new.
	searchedClasses := allClasses select: [:cls | self shouldSearchInClass: cls ].

	[
		| numUnused |

		numUnused := unusedMethods size.
		searchedClasses do: [:cls | 
			self searchInClass: cls theNonMetaclass.
			self searchInClass: cls theMetaclass.
		].
		numUnused < unusedMethods size.             
	] whileTrue.

	^ unusedMethods

]

{ #category : #searching }
UnusedCodeFinder >> searchInClass: cls [
	cls selectorsAndMethodsDo: [ :sel :mth |
		(self checkIfUsed: mth) ifFalse: [ 
			unusedMethods add: mth.
		].
	].

]

{ #category : #queries }
UnusedCodeFinder >> shouldSearchInClass: aClass [
	"Return `true`, if given class SHOULD be searched for
	 unused code, `false` otherwise."

	 (aClass inheritsFrom: Nativizer) ifTrue: [ ^ true ].
	 (aClass inheritsFrom: ABI) ifTrue: [ ^ true ].
	 ^ false

"      ^ false"
"      ^ #("
"       #'Powerlang-Core-Assembler' "
" '/      #'Powerlang-Core-Assembler-Intel' "
" '/      #'Powerlang-Core-Assembler-Parser' "
" '/      #'Powerlang-Core-Assembler-RISCV' "
" '/      #'Powerlang-Core-Assembler-Tools' "
" '/      #'Powerlang-Core-Building' "
" '/      #'Powerlang-Core-Emulation' "
" '/      #'Powerlang-Core-Manifest' "
" '/      #'Powerlang-Core-Metaphysics' "
" '/      #'Powerlang-Core-Mirrors' "
"       #'Powerlang-Core-Nativization' "
"       #'Powerlang-Core-OCompiler' "
"       #'Powerlang-Core-OCompiler-IR' "
"       #'Powerlang-Core-SCompiler' "
"       #'Powerlang-Core-SCompiler-Bindings' "
"       #'Powerlang-Core-SCompiler-Smalltalk' "
"       #'Powerlang-Core-SCompiler-Smalltalk-Parser' "
"       #'Powerlang-Core-SExpressions'"
"     ) includes: aClass category."

]

{ #category : #accessing }
UnusedCodeFinder >> unusedMethods [
	^ unusedMethods
]

{ #category : #accessing }
UnusedCodeFinder >> unusedMethodsByClass [
	| unusedMethodsByClass |

	unusedMethodsByClass := Dictionary new.
	unusedMethods notEmptyOrNil ifTrue: [ 
		unusedMethods do: [:each | 
			(unusedMethodsByClass at: each mclass ifAbsentPut: Set new) add: each
		]
	].
	^ unusedMethodsByClass 

]
