Class {
	#name : #AMD64CodeGeneratorTest,
	#superclass : #TestCase,
	#instVars : [
		'assembler'
	],
	#category : #'Powerlang-Tests-Assembler-JIT'
}

{ #category : #utilities }
AMD64CodeGeneratorTest class >> generateTest: aMessage [
	| assembler bytes testSelector source |

	"  For now, only handle messages with zero or more INTEGER arguments"
	(aMessage arguments allSatisfy: [:e | e isInteger ]) ifFalse: [ ^ self ].

	assembler := NativizationTarget x86_64_linux_gnu newNativizer.
	[ 
		aMessage sendTo: assembler.
		bytes := assembler bytes.
		bytes isEmpty ifTrue:[ ^ self ].
	] on: Error do:[ ^self ].

	testSelector := String streamContents: [ :s|
		s nextPutAll: 'test'.
		s nextPutAll: (aMessage selector capitalized copyReplaceAll: $: with: $_).
		aMessage arguments notEmpty ifTrue: [ 
			aMessage arguments do: [:e | 
				s nextPut: $_.
				s nextPutAll: (e printString replaceAll: $- with: $m).
			].
		].
	].

	source := '<1s>
	
	assembler perform: <2s> withArguments: <3s>.
	self 
		assert: (assembler bytes)
		equals: (<4s>)
	' expandMacrosWith: testSelector
				  with: aMessage selector storeString
				  with: aMessage arguments storeString
				  with: bytes storeString.
	
	self compile: source classified: #'tests - generated 2'
	
	"
	self generateTests
	"

]

{ #category : #utilities }
AMD64CodeGeneratorTest class >> generateTests [
	"JITAssemblerAMD64 selectorsDo: [ :sel | sel isUnary ifTrue:[ self generateTest: sel ] ]."

	| messages |

	Assembler class 
			compile: 'new ^ MessageCollector for: super new useAMD64 wordSize: 8' 
			classified: #'temporary'.
	[ 
		MessageCollector messages removeAll.
		KernelBuilderTest new setUp; test400completeNativizedSegmentWithBase.
		messages := MessageCollector messages copy.
		MessageCollector messages copy.
	] ensure: [ 
		MessageCollector messages removeAll.
		Assembler class removeSelector: #new.
	].

	self halt.    
	messages do: [:message | self generateTest: message ].

]

{ #category : #running }
AMD64CodeGeneratorTest >> setUp [
	super setUp.
	assembler := NativizationTarget x86_64_linux_gnu newNativizer.
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAddAtoR [
	
	assembler perform: #addAtoR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 1 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAddDoubleX1toX0 [
	
	assembler perform: #addDoubleX1toX0 withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[242 15 88 193])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAddRconstant__1 [
	
	assembler perform: #addRwithImmediate: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 192 1])

]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAddRconstant__2 [
	
	assembler perform: #addRwithImmediate: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 192 2])

]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAddRconstant__4 [
	
	assembler perform: #addRwithImmediate: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 192 4])

]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAddRconstant__8 [
	
	assembler perform: #addRwithImmediate: withArguments: #(8).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 192 8])

]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAddRconstant__m2 [
	
	assembler perform: #addRwithImmediate: withArguments: #(-2).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 192 254])

]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAddToTconstant__1 [
	
	assembler perform: #addTwithImmediate: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 193 1])

]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAddTtoR [
	
	assembler perform: #addTtoR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 1 200])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testAndRwithA [
	
	assembler perform: #andRwithA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 33 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testBreakpoint [
	
	assembler perform: #breakpoint withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[204])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testBuildFrame [
	
	assembler perform: #buildFrame withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[85 72 137 229])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCallIndirectA [
	
	assembler perform: #callIndirectA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[255 18])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCallIndirectM [
	
	assembler perform: #callIndirectM withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[255 19])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testCallR [
	
	assembler callR.
	self 
		assert: (assembler bytes)
		equals: (#[255 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testClearFPUFlags [
	
	assembler perform: #clearFPUFlags withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[219 226])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testClearRhighHalf [
	
	assembler clearRhigh32.
	self 
		assert: (assembler bytes)
		equals: (#[137 192])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testClearRintegerBit [
	
	assembler perform: #clearRintegerBit withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 255 200])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testClearSafeRintegerBit [
	
	assembler perform: #clearSafeRintegerBit withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[36 254])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testCompareAwithFalse [
	
	assembler compareAwithFalse.
	self 
		assert: (assembler bytes)
		equals: (#[76 57 242])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testCompareAwithTrue [
	
	assembler compareAwithTrue.
	self 
		assert: (assembler bytes)
		equals: (#[76 57 234])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareEqualDoubleX0withAindirect [
	
	assembler perform: #compareEqualDoubleX0withAindirect withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[242 15 194 2 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareLessThanDoubleX0withAindirect [
	
	assembler perform: #compareLessThanDoubleX0withAindirect withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[242 15 194 2 1])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareRwithA [
	
	assembler perform: #compareRwithA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 57 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareRwithFalse [
	
	assembler perform: #compareRwithFalse withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[76 57 240])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareRwithImmediate__0 [
	
	assembler perform: #compareRwithImmediate: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 248 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareRwithNil [
	
	assembler perform: #compareRwithNil withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[76 57 224])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareRwithSmallInteger__0 [
	
	assembler perform: #compareRwithSmallInteger: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 248 1])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareRwithTrue [
	
	assembler perform: #compareRwithTrue withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[76 57 232])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareSwithTindex__1 [
	
	assembler perform: #compareSwithTindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 59 49])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareSwithTindex__11 [
	
	assembler perform: #compareSwithTindex: withArguments: #(11).
	self 
		assert: (assembler bytes)
		equals: (#[72 59 113 80])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareSwithTindex__13 [
	
	assembler perform: #compareSwithTindex: withArguments: #(13).
	self 
		assert: (assembler bytes)
		equals: (#[72 59 113 96])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareSwithTindex__3 [
	
	assembler perform: #compareSwithTindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 59 113 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareSwithTindex__5 [
	
	assembler perform: #compareSwithTindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 59 113 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareSwithTindex__7 [
	
	assembler perform: #compareSwithTindex: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 59 113 48])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareSwithTindex__9 [
	
	assembler perform: #compareSwithTindex: withArguments: #(9).
	self 
		assert: (assembler bytes)
		equals: (#[72 59 113 64])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareTwithA [
	
	assembler perform: #compareTwithA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 57 209])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testCompareTwithImmediate__0 [
	
	assembler perform: #compareTwithImmediate: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 249 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testConvertAtoNativeInteger [
	
	assembler perform: #convertAtoNativeInteger withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 209 250])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testConvertRtoNativeInteger [
	
	assembler perform: #convertRtoNativeInteger withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 209 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testConvertRtoSmallInteger [
	
	assembler perform: #convertRtoSmallInteger withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 209 224 72 255 192])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testConvertTtoNativeInteger [
	
	assembler perform: #convertTtoNativeInteger withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 209 249])
	
]

{ #category : #'as yet unclassified' }
AMD64CodeGeneratorTest >> testDecRindirect [
	
	assembler perform: #decRindirect withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 255 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDiscardArguments__1 [
	
	assembler perform: #discardArguments: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 196 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDiscardArguments__2 [
	
	assembler perform: #discardArguments: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 196 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDiscardArguments__3 [
	
	assembler perform: #discardArguments: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 196 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDiscardArguments__4 [
	
	assembler perform: #discardArguments: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 196 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDiscardArguments__5 [
	
	assembler perform: #discardArguments: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 196 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDiscardArguments__6 [
	
	assembler perform: #discardArguments: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 196 48])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDiscardArguments__7 [
	
	assembler perform: #discardArguments: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 196 56])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDivideDoubleX0byX1 [
	
	assembler perform: #divideDoubleX0byX1 withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[242 15 94 193])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDivideRbyT [
	
	assembler perform: #extendRtoAandDividebyT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 153 72 247 249])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testDropTopOfFPU [
	
	assembler dropTopOfFPU.
	self 
		assert: (assembler bytes)
		equals: (#[221 216])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testDropTos__1 [
	
	assembler perform: #dropTos: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 196 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testEnsureRintegerBit [
	
	assembler perform: #setRintegerBit withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[12 1])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testEnsureSafeRintegerBit [
	
	assembler perform: #setSafeRintegerBit withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[12 1])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testExchangeRindirectWithT [
	
	assembler perform: #exchangeRindirectWithT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 135 8])
	
]

{ #category : #'as yet unclassified' }
AMD64CodeGeneratorTest >> testInitializeS [
	
	assembler perform: #initializeS withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 198])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testJumpToMindex__1 [
	
	assembler perform: #jumpToMindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[255 35])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLabeledIntegerBitTestOfR [
	
	assembler perform: #labeledIntegerBitTestOfR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[168 1 116 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLabeledIntegerBitTestOfT [
	
	assembler perform: #labeledIntegerBitTestOfT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[246 193 1 116 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLabeledIntegerNativizationOfA [
	
	assembler perform: #labeledIntegerNativizationOfA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 209 250 115 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLabeledIntegerNativizationOfR [
	
	assembler perform: #labeledIntegerNativizationOfR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 209 248 115 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLabeledIntegerNativizationOfT [
	
	assembler perform: #labeledIntegerNativizationOfT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 209 249 115 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLabeledNonIntegerBitTestOfR [
	
	assembler perform: #labeledNonIntegerBitTestOfR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[168 1 117 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLeadingRzeroCount [
	
	assembler perform: #leadingRzeroCount withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[243 72 15 189 192])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithAindex__1 [
	
	assembler perform: #loadAwithAindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 18])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithAindex__2 [
	
	assembler perform: #loadAwithAindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 82 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithAindex__3 [
	
	assembler perform: #loadAwithAindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 82 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithAindex__4 [
	
	assembler perform: #loadAwithAindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 82 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithAindex__5 [
	
	assembler perform: #loadAwithAindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 82 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithAindex__6 [
	
	assembler perform: #loadAwithAindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 82 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithEindex__1 [
	
	assembler perform: #loadAwithEindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 23])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithEindex__2 [
	
	assembler perform: #loadAwithEindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 87 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithEindex__3 [
	
	assembler perform: #loadAwithEindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 87 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithEindex__4 [
	
	assembler perform: #loadAwithEindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 87 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithEindex__5 [
	
	assembler perform: #loadAwithEindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 87 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithEindex__6 [
	
	assembler perform: #loadAwithEindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 87 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__3 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__4 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__5 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__6 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m10 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-10).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 168])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m11 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-11).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 160])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m12 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-12).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 152])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m13 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-13).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 144])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m17 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-17).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 149 112 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m18 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-18).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 149 104 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m2 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 232])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m20 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-20).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 149 88 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m3 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 224])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m4 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 216])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m5 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m6 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 200])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m7 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-7).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 192])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m8 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-8).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 184])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithFPindex__m9 [
	
	assembler perform: #loadAwithFPindex: withArguments: #(-9).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 85 176])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testLoadAwithFalse [
	
	assembler loadAwithFalse.
	self 
		assert: (assembler bytes)
		equals: (#[76 137 242])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithLiteral__1405006117752879898543142606244511569936384000000000 [
	
	assembler perform: #loadAwithLiteral: withArguments: #(1405006117752879898543142606244511569936384000000000).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 83 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithNil [
	
	assembler perform: #loadAwithNil withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[76 137 226])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithR [
	
	assembler perform: #loadAwithR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 194])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithRoffsetAtA [
	
	assembler perform: #loadAwithRoffsetAtA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 139 20 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithS [
	
	assembler perform: #loadAwithS withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 242])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSindex__1 [
	
	assembler perform: #loadAwithSindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 22])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSindex__16 [
	
	assembler perform: #loadAwithSindex: withArguments: #(16).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 86 120])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSindex__2 [
	
	assembler perform: #loadAwithSindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 86 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSindex__3 [
	
	assembler perform: #loadAwithSindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 86 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSindex__4 [
	
	assembler perform: #loadAwithSindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 86 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSindex__5 [
	
	assembler perform: #loadAwithSindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 86 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__0 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__1 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 3 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__10 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(10).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 21 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__100 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(100).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 201 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__1000 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(1000).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 209 7 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__1023 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(1023).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 7 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__1024 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(1024).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 8 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__1048575 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(1048575).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 255 31 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__1114112 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(1114112).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 0 34 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__12 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(12).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 25 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__12288 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(12288).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 96 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__123 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(123).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 247 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__124 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(124).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 249 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__125 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(125).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 251 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__127 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(127).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__128 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(128).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__13 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(13).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 27 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__14 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(14).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 29 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__15 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(15).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 31 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__16 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(16).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 33 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__160 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(160).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 65 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__162 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(162).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 69 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__16273 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(16273).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 35 127 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__16383 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(16383).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 127 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__16384 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(16384).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 128 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__1664525 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(1664525).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 27 204 50 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__16777215 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(16777215).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 255 255 1])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__192 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(192).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 129 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__2 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 5 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__2047 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(2047).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 15 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__2048 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(2048).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 16 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__216 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(216).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 177 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__224 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(224).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 193 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__240 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(240).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 225 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__248 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(248).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 241 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__251 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(251).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 247 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__255 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(255).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__256 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(256).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 2 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__268435455 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(268435455).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 255 255 31])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__3 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 7 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__30000 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(30000).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 97 234 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__31 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(31).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 63 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__32 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(32).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 65 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__32752 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(32752).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 225 255 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__32767 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(32767).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 255 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__32768 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(32768).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 0 1 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__34 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(34).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 69 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__35 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(35).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 71 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__36 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(36).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 73 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__39 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(39).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 79 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__4 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 9 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__41 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(41).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 83 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__42 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(42).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 85 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__4294967295 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(4294967295).
	self 
		assert: (assembler bytes)
		equals: (#[72 186 255 255 255 255 1 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__4294967296 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(4294967296).
	self 
		assert: (assembler bytes)
		equals: (#[72 186 1 0 0 0 2 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__43 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(43).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 87 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__45 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(45).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 91 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__4503599627370496 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(4503599627370496).
	self 
		assert: (assembler bytes)
		equals: (#[72 186 1 0 0 0 0 0 32 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__46 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(46).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 93 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__48 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(48).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 97 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__49152 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(49152).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 128 1 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__5 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 11 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__50 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(50).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 101 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__5000 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(5000).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 17 39 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__54 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(54).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 109 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__54625 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(54625).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 195 170 1 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__55 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(55).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 111 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__55296 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(55296).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 176 1 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__56320 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(56320).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 184 1 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__57 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(57).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 115 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__57344 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(57344).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 192 1 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__58 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(58).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 117 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__59 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(59).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 119 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__6 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 13 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__60 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(60).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 121 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__62 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(62).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 125 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__63 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(63).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 127 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__64 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(64).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 129 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__65535 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(65535).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 255 1 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__65536 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(65536).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 0 2 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__7 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 15 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__75 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(75).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 151 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__8 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(8).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 17 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__8192 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(8192).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 1 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__8204 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(8204).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 25 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__8239 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(8239).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 95 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__8287 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(8287).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 191 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__87 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(87).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 175 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__9 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(9).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 19 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__90 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(90).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 181 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__9007199254740992 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(9007199254740992).
	self 
		assert: (assembler bytes)
		equals: (#[72 186 1 0 0 0 0 0 64 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__91 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(91).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 183 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__92 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(92).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 185 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__93 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(93).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 187 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__94 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(94).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 189 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__95 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(95).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 191 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__96 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(96).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 193 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__m1 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(-1).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 255 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__m1023 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(-1023).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 3 248 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadAwithSmallInteger__m2 [
	
	assembler perform: #loadAwithSmallInteger: withArguments: #(-2).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 194 253 255 255 255])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testLoadAwithTrue [
	
	assembler loadAwithTrue.
	self 
		assert: (assembler bytes)
		equals: (#[76 137 234])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadEwithAddressOfRatA [
	
	assembler perform: #loadEwithAddressOfRatA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 141 124 208 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadEwithNil [
	
	assembler perform: #loadEwithNil withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[76 137 231])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadEwithR [
	
	assembler perform: #loadEwithR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 199])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadFPwithR [
	
	assembler perform: #loadFPwithR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 197])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testLoadFPwithSP [
	
	assembler loadFPwithSP.
	self 
		assert: (assembler bytes)
		equals: (#[72 137 229])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadLargeX0withRindirect [
	
	assembler perform: #loadLargeX0withRindirect withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[102 72 15 110 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadLargeX1withAindirect [
	
	assembler perform: #loadLargeX1withAindirect withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[102 72 15 110 10])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadLongMwithIPoffset__m34 [
	
	assembler perform: #loadLongMwithIPoffset: withArguments: #(-34).
	self 
		assert: (assembler bytes)
		equals: (#[139 29 216 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadLongRwithRatOffsetA [
	
	assembler perform: #loadLongRwithRatOffsetA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[139 4 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadLongSwithRindex__0 [
	
	assembler perform: #loadLongSwithRindex: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[139 112 252])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMXCSRfromA [
	
	assembler perform: #loadMXCSRfromA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[15 174 18])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithA [
	
	assembler perform: #loadMwithA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 211])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithMindex__2 [
	
	assembler perform: #loadMwithMindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 91 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithMindex__4 [
	
	assembler perform: #loadMwithMindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 91 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithRindex__1 [
	
	assembler perform: #loadMwithRindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithTindex__10 [
	
	assembler perform: #loadMwithTindex: withArguments: #(10).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 89 72])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithTindex__12 [
	
	assembler perform: #loadMwithTindex: withArguments: #(12).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 89 88])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithTindex__14 [
	
	assembler perform: #loadMwithTindex: withArguments: #(14).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 89 104])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithTindex__15 [
	
	assembler perform: #loadMwithTindex: withArguments: #(15).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 89 112])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithTindex__2 [
	
	assembler perform: #loadMwithTindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 89 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithTindex__4 [
	
	assembler perform: #loadMwithTindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 89 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithTindex__6 [
	
	assembler perform: #loadMwithTindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 89 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadMwithTindex__8 [
	
	assembler perform: #loadMwithTindex: withArguments: #(8).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 89 56])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRconvertingDoublePointedByR [
	
	assembler perform: #loadRconvertingDoublePointedByR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[242 72 15 44 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithA [
	
	assembler perform: #loadRwithA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithArgPointer [
	
	assembler perform: #loadRwithArgPointer withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 141 69 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithE [
	
	assembler perform: #loadRwithE withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithEindex__1 [
	
	assembler perform: #loadRwithEindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 7])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithEindex__2 [
	
	assembler perform: #loadRwithEindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 71 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithEindex__3 [
	
	assembler perform: #loadRwithEindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 71 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithEindex__4 [
	
	assembler perform: #loadRwithEindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 71 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithEindex__5 [
	
	assembler perform: #loadRwithEindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 71 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithEindex__6 [
	
	assembler perform: #loadRwithEindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 71 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithEindex__7 [
	
	assembler perform: #loadRwithEindex: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 71 48])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFP [
	
	assembler perform: #loadRwithFP withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 232])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__1 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__3 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__4 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__5 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__6 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__7 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 48])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__8 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(8).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 56])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__9 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(9).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 64])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m10 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-10).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 168])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m11 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-11).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 160])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m12 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-12).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 152])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m13 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-13).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 144])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m14 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-14).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 136])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m15 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-15).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 128])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m16 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-16).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 133 120 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m17 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-17).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 133 112 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m18 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-18).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 133 104 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m19 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-19).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 133 96 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m2 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 232])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m20 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-20).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 133 88 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m21 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-21).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 133 80 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m3 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 224])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m4 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 216])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m5 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m6 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 200])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m7 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-7).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 192])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m8 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-8).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 184])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFPindex__m9 [
	
	assembler perform: #loadRwithFPindex: withArguments: #(-9).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 69 176])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithFalse [
	
	assembler perform: #loadRwithFalse withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[76 137 240])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithImmediate__0 [
	
	assembler perform: #loadRwithImmediate: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 0 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithM [
	
	assembler perform: #loadRwithM withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 216])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithMindex__2 [
	
	assembler perform: #loadRwithMindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 67 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithNil [
	
	assembler perform: #loadRwithNil withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[76 137 224])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithRatA [
	
	assembler perform: #loadRwithRatA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 139 68 208 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithRatOffsetA [
	
	assembler perform: #loadRwithRatOffsetA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 139 4 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithRindex__1 [
	
	assembler perform: #loadRwithRindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithRindex__2 [
	
	assembler perform: #loadRwithRindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 64 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithRindex__3 [
	
	assembler perform: #loadRwithRindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 64 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithRindex__4 [
	
	assembler perform: #loadRwithRindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 64 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithRindex__5 [
	
	assembler perform: #loadRwithRindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 64 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithRindex__6 [
	
	assembler perform: #loadRwithRindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 64 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithRindex__7 [
	
	assembler perform: #loadRwithRindex: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 64 48])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithS [
	
	assembler perform: #loadRwithS withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 240])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSPindex__2 [
	
	assembler perform: #loadRwithSPindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 68 36 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSPindex__3 [
	
	assembler perform: #loadRwithSPindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 68 36 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSPindex__4 [
	
	assembler perform: #loadRwithSPindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 68 36 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__1 [
	
	assembler perform: #loadRwithSindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 6])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__10 [
	
	assembler perform: #loadRwithSindex: withArguments: #(10).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 72])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__11 [
	
	assembler perform: #loadRwithSindex: withArguments: #(11).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 80])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__12 [
	
	assembler perform: #loadRwithSindex: withArguments: #(12).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 88])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__13 [
	
	assembler perform: #loadRwithSindex: withArguments: #(13).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 96])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__14 [
	
	assembler perform: #loadRwithSindex: withArguments: #(14).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 104])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__15 [
	
	assembler perform: #loadRwithSindex: withArguments: #(15).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 112])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__16 [
	
	assembler perform: #loadRwithSindex: withArguments: #(16).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 120])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__17 [
	
	assembler perform: #loadRwithSindex: withArguments: #(17).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 134 128 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__18 [
	
	assembler perform: #loadRwithSindex: withArguments: #(18).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 134 136 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__19 [
	
	assembler perform: #loadRwithSindex: withArguments: #(19).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 134 144 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__2 [
	
	assembler perform: #loadRwithSindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__3 [
	
	assembler perform: #loadRwithSindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__4 [
	
	assembler perform: #loadRwithSindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__5 [
	
	assembler perform: #loadRwithSindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__6 [
	
	assembler perform: #loadRwithSindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__7 [
	
	assembler perform: #loadRwithSindex: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 48])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__8 [
	
	assembler perform: #loadRwithSindex: withArguments: #(8).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 56])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSindex__9 [
	
	assembler perform: #loadRwithSindex: withArguments: #(9).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 70 64])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__0 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__1 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 3 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__10 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(10).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 21 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__100 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(100).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 201 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__1000 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(1000).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 209 7 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__10000 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(10000).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 33 78 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__1000000 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(1000000).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 129 132 30 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__1024 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(1024).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 8 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__1075 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(1075).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 103 8 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__119886 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(119886).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 157 168 3 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__12 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(12).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 25 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__126 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(126).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 253 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__127 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(127).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 255 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__128 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(128).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__13 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(13).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 27 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__131072 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(131072).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 0 4 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__13131 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(13131).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 151 102 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__14 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(14).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 29 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__140000 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(140000).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 193 69 4 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__15 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(15).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 31 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__159 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(159).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 63 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__16 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(16).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 33 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__160 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(160).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 65 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__16384 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(16384).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 128 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__1664525 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(1664525).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 27 204 50 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__16777216 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(16777216).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 0 0 2])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__18 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(18).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 37 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__192 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(192).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 129 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__2 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 5 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__20 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(20).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 41 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__21 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(21).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 43 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__22 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(22).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 45 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__23 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(23).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 47 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__24 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(24).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 49 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__248 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(248).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 241 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__25 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(25).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 51 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__253 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(253).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 251 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__255 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(255).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 255 1 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__256 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(256).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 2 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__26 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(26).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 53 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__27 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(27).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 55 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__3 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 7 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__3000 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(3000).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 113 23 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__309 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(309).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 107 2 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__31 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(31).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 63 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__32 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(32).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 65 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__32767 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(32767).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 255 255 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__32768 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(32768).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 0 1 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__4 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 9 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__4000 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(4000).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 65 31 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__4096 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(4096).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 32 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__42 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(42).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 85 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__4294967296 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(4294967296).
	self 
		assert: (assembler bytes)
		equals: (#[72 184 1 0 0 0 2 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__48 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(48).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 97 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__5 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 11 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__50 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(50).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 101 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__5381 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(5381).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 11 42 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__54 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(54).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 109 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__55 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(55).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 111 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__6 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 13 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__64 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(64).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 129 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__7 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 15 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 17 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8192 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8192).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8194 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8194).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 5 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8195 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8195).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 7 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8197 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8197).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 11 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8211 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8211).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 39 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8212 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8212).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 41 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8216 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8216).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 49 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8217 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8217).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 51 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8220 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8220).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 57 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8221 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8221).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 59 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8226 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8226).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 69 64 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8592 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8592).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 33 67 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8593 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8593).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 35 67 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8594 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8594).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 37 67 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8595 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8595).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 39 67 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8804 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8804).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 201 68 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8805 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8805).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 203 68 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8853 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8853).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 43 69 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__8855 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(8855).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 47 69 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__9 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(9).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 19 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m1 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-1).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 255 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m10 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-10).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 237 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m12 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-12).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 233 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m14 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-14).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 229 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m15 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-15).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 227 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m16 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-16).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 225 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m18 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-18).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 221 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m2 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-2).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 253 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m20 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-20).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 217 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m24 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-24).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 209 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m3 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-3).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 251 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m32 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-32).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 193 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m4096 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-4096).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 1 224 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m5 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-5).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 247 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m6 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-6).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 245 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m8 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-8).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 192 241 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithSmallInteger__m9007199254740992 [
	
	assembler perform: #loadRwithSmallInteger: withArguments: #(-9007199254740992).
	self 
		assert: (assembler bytes)
		equals: (#[72 184 1 0 0 0 0 0 192 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithT [
	
	assembler perform: #loadRwithT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 200])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testLoadRwithTIBatR [
	
	assembler loadRwithTIBatR.
	self 
		assert: (assembler bytes)
		equals: (#[101 72 139 4 197 0 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithThreadVariableAtR [
	
	assembler perform: #loadRwithThreadVariableAtR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[101 72 139 4 197 128 20 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadRwithTrue [
	
	assembler perform: #loadRwithTrue withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[76 137 232])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testLoadSPwithFP [
	
	assembler loadSPwithFP.
	self 
		assert: (assembler bytes)
		equals: (#[72 137 236])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadSwithAddressOfSatA [
	
	assembler perform: #loadSwithAddressOfSatA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 141 116 214 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadSwithNil [
	
	assembler perform: #loadSwithNil withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[76 137 230])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadSwithRindex__3 [
	
	assembler perform: #loadSwithRindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 112 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadSwithRindex__4 [
	
	assembler perform: #loadSwithRindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 112 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithA [
	
	assembler perform: #loadTwithA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 209])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithAindex__3 [
	
	assembler perform: #loadTwithAindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 74 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithEindex__1 [
	
	assembler perform: #loadTwithEindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 15])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithEindex__2 [
	
	assembler perform: #loadTwithEindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 79 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithEindex__3 [
	
	assembler perform: #loadTwithEindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 79 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithEindex__4 [
	
	assembler perform: #loadTwithEindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 79 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithFPindex__3 [
	
	assembler perform: #loadTwithFPindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 77 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithFPindex__4 [
	
	assembler perform: #loadTwithFPindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 77 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithFPindex__5 [
	
	assembler perform: #loadTwithFPindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 77 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithFPindex__6 [
	
	assembler perform: #loadTwithFPindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 77 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithImmediate__0 [
	
	assembler perform: #loadTwithImmediate: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[72 199 193 0 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithR [
	
	assembler perform: #loadTwithR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 193])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadTwithTindex__1 [
	
	assembler perform: #loadTwithTindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 139 9])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadX0withRasDouble [
	
	assembler perform: #loadX0withRasDouble withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[242 72 15 42 192])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadX1roundingX0 [
	
	assembler perform: #roundDoubleX0intoX1 withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[102 15 58 11 200 3])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadZeroExtendByteRwithRatA [
	
	assembler perform: #loadZeroExtendByteRwithRatA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 15 182 68 16 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadZeroExtendByteRwithSPatA [
	
	assembler perform: #loadZeroExtendByteRwithSPatA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 15 182 68 20 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadZeroExtendLongRwithRatA [
	
	assembler perform: #loadZeroExtendLongRwithRatA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[139 68 144 252])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLoadZeroExtendShortRwithRoffset__m8 [
	
	assembler perform: #loadZeroExtendShortRwithRoffset: withArguments: #(-8).
	self 
		assert: (assembler bytes)
		equals: (#[72 15 183 64 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testLock [
	
	assembler perform: #lock withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[240])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testMoveTslots [
	
	assembler perform: #moveTslots withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[243 72 165])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testMoveX0toR [
	
	assembler perform: #moveX0toR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[102 72 15 126 192])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testMultiplyDoubleX0byX1 [
	
	assembler perform: #multiplyDoubleX0byX1 withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[242 15 89 193])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testMultiplyRbyA [
	
	assembler perform: #multiplyRbyAwideningToA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 247 234])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testOrRwithA [
	
	assembler perform: #orRwithA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 9 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopA [
	
	assembler perform: #popA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[90])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopE [
	
	assembler perform: #popE withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[95])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopFP [
	
	assembler perform: #popFP withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[93])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopFalse [
	
	assembler perform: #popFalse withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[65 94])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopG [
	
	assembler perform: #popG withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[65 95])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopM [
	
	assembler perform: #popM withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[91])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopNil [
	
	assembler perform: #popNil withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[65 92])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopR [
	
	assembler perform: #popR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[88])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopS [
	
	assembler perform: #popS withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[94])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopSPindirect [
	
	assembler perform: #popSPindirect withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[143 4 36])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testPopT [
	
	assembler popT.
	self 
		assert: (assembler bytes)
		equals: (#[89])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPopTrue [
	
	assembler perform: #popTrue withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[65 93])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushA [
	
	assembler perform: #pushA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[82])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushE [
	
	assembler perform: #pushE withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[87])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testPushFP [
	
	assembler pushFP.
	self 
		assert: (assembler bytes)
		equals: (#[85])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushFalse [
	
	assembler perform: #pushFalse withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[65 86])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushG [
	
	assembler perform: #pushG withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[65 87])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushImmediate__0 [
	
	assembler perform: #pushImm: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[106 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushIndirectR [
	
	assembler perform: #pushIndirectR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[255 48])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushM [
	
	assembler perform: #pushM withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[83])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushNil [
	
	assembler perform: #pushNil withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[65 84])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushR [
	
	assembler perform: #pushR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[80])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushS [
	
	assembler perform: #pushS withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[86])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushSmallInteger__0 [
	
	assembler perform: #pushSmallInteger: withArguments: #(0).
	self 
		assert: (assembler bytes)
		equals: (#[106 1])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushSmallInteger__1 [
	
	assembler perform: #pushSmallInteger: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[106 3])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushSmallInteger__2 [
	
	assembler perform: #pushSmallInteger: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[106 5])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushSmallInteger__3 [
	
	assembler perform: #pushSmallInteger: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[106 7])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushT [
	
	assembler perform: #pushT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[81])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testPushTrue [
	
	assembler perform: #pushTrue withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[65 85])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testReadFPUStatusOnA [
	
	assembler readFPUStatusOnA.
	self 
		assert: (assembler bytes)
		equals: (#[155 221 58])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testReserveStackSlots__13 [
	
	assembler perform: #reserveStackSlots: withArguments: #(13).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 236 104])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testReserveStackSlots__2 [
	
	assembler perform: #reserveStackSlots: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 236 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testReserveStackSlots__3 [
	
	assembler perform: #reserveStackSlots: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 236 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testReserveStackSlots__4 [
	
	assembler perform: #reserveStackSlots: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 236 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testReserveStackSlots__5 [
	
	assembler perform: #reserveStackSlots: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 236 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testRestoreCallerEnvironment [
	
	assembler perform: #restoreCallerEnvironment withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 139 125 232])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testRestoreCallerFrame [
	
	assembler perform: #restoreCallerFrame withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 236 93])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testRestoreCallerM [
	
	assembler perform: #restoreCallerM withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 139 93 240])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testRestoreCallerSelf [
	
	assembler perform: #restoreCallerSelf withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 139 117 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testReturn [
	
	assembler perform: #return withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[195])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testSaveCallerFrame [
	
	assembler perform: #saveCallerFrame withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[85 72 137 229])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testShiftLeftRwithT [
	
	assembler perform: #shiftLeftRwithT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 211 224])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testShiftRightRwithT [
	
	assembler perform: #shiftRightRwithT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 211 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testShiftRleft__1 [
	
	assembler perform: #shiftRleft: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 209 224])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testSqrtDoubleX0 [
	
	assembler perform: #sqrtDoubleX0 withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[242 15 81 192])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testStoreAinThreadVariableAtIndexR [
	
	assembler storeAinThreadVariableAtIndexR.
	self 
		assert: (assembler bytes)
		equals: (#[101 72 137 20 197 128 20 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreAinTindex__1 [
	
	assembler perform: #storeAinTindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 17])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreAinTindex__2 [
	
	assembler perform: #storeAinTindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 81 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreByteTinRatA [
	
	assembler perform: #storeByteTinRatA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[136 76 16 255])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testStoreDoubleResultInRindirect [
	
	assembler storeDoubleResultInRindirect.
	self 
		assert: (assembler bytes)
		equals: (#[102 72 15 126 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreEinRindex__3 [
	
	assembler perform: #storeEinRindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 120 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreEinRindex__4 [
	
	assembler perform: #storeEinRindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 120 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreEinRindex__5 [
	
	assembler perform: #storeEinRindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 120 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreLargeX0inA [
	
	assembler perform: #storeLargeX0inA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[102 72 15 126 2])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreLargeX0inT [
	
	assembler perform: #storeLargeX0inT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[102 72 15 126 1])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreLongTinRatA [
	
	assembler perform: #storeLongTinRatA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[137 76 144 252])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreLongTinRatOffsetA [
	
	assembler perform: #storeLongTinRatOffsetA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[137 12 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreMXCSRintoA [
	
	assembler perform: #storeMXCSRintoA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[15 174 26])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinAindex__2 [
	
	assembler perform: #storeRinAindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 66 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinEindex__1 [
	
	assembler perform: #storeRinEindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 7])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinEindex__2 [
	
	assembler perform: #storeRinEindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 71 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinEindex__3 [
	
	assembler perform: #storeRinEindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 71 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinEindex__6 [
	
	assembler perform: #storeRinEindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 71 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m10 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-10).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 168])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m11 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-11).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 160])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m12 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-12).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 152])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m13 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-13).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 144])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m14 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-14).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 136])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m15 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-15).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 128])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m16 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-16).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 133 120 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m17 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-17).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 133 112 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m18 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-18).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 133 104 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m19 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-19).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 133 96 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m2 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-2).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 232])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m20 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-20).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 133 88 255 255 255])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m3 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-3).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 224])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m4 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-4).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 216])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m5 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-5).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m6 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-6).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 200])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m7 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-7).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 192])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m8 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-8).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 184])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinFPindex__m9 [
	
	assembler perform: #storeRinFPindex: withArguments: #(-9).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 69 176])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__1 [
	
	assembler perform: #storeRinSindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 6])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__10 [
	
	assembler perform: #storeRinSindex: withArguments: #(10).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 72])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__11 [
	
	assembler perform: #storeRinSindex: withArguments: #(11).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 80])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__12 [
	
	assembler perform: #storeRinSindex: withArguments: #(12).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 88])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__13 [
	
	assembler perform: #storeRinSindex: withArguments: #(13).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 96])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__14 [
	
	assembler perform: #storeRinSindex: withArguments: #(14).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 104])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__15 [
	
	assembler perform: #storeRinSindex: withArguments: #(15).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 112])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__16 [
	
	assembler perform: #storeRinSindex: withArguments: #(16).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 120])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__17 [
	
	assembler perform: #storeRinSindex: withArguments: #(17).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 134 128 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__18 [
	
	assembler perform: #storeRinSindex: withArguments: #(18).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 134 136 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__19 [
	
	assembler perform: #storeRinSindex: withArguments: #(19).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 134 144 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__2 [
	
	assembler perform: #storeRinSindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__3 [
	
	assembler perform: #storeRinSindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__4 [
	
	assembler perform: #storeRinSindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__5 [
	
	assembler perform: #storeRinSindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__6 [
	
	assembler perform: #storeRinSindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__7 [
	
	assembler perform: #storeRinSindex: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 48])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__8 [
	
	assembler perform: #storeRinSindex: withArguments: #(8).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 56])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinSindex__9 [
	
	assembler perform: #storeRinSindex: withArguments: #(9).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 70 64])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinTindex__1 [
	
	assembler perform: #storeRinTindex: withArguments: #(1).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 1])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinTindex__2 [
	
	assembler perform: #storeRinTindex: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 65 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinTindex__3 [
	
	assembler perform: #storeRinTindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 65 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinTindex__4 [
	
	assembler perform: #storeRinTindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 65 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreRinTindex__5 [
	
	assembler perform: #storeRinTindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 65 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreShortAinRoffset__m8 [
	
	assembler perform: #storeShortAinRoffset: withArguments: #(-8).
	self 
		assert: (assembler bytes)
		equals: (#[102 137 80 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreShortTinRatOffsetA [
	
	assembler perform: #storeShortTinRatOffsetA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[102 137 12 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreSinRindex__3 [
	
	assembler perform: #storeSinRindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 112 16])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testStoreTIBatRwithA [
	
	assembler storeTIBatRwithA.
	self 
		assert: (assembler bytes)
		equals: (#[101 72 137 20 197 0 0 0 0])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreTinRatA [
	
	assembler perform: #storeTinRatA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 76 208 248])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreTinRatOffsetA [
	
	assembler perform: #storeTinRatOffsetA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 137 12 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreTinRindex__3 [
	
	assembler perform: #storeTinRindex: withArguments: #(3).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 72 16])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreTinRindex__4 [
	
	assembler perform: #storeTinRindex: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 72 24])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreTinRindex__5 [
	
	assembler perform: #storeTinRindex: withArguments: #(5).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 72 32])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreTinRindex__6 [
	
	assembler perform: #storeTinRindex: withArguments: #(6).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 72 40])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testStoreTinRindex__7 [
	
	assembler perform: #storeTinRindex: withArguments: #(7).
	self 
		assert: (assembler bytes)
		equals: (#[72 137 72 48])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testSubAfromR [
	
	assembler perform: #subAfromR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 41 208])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testSubAfromT [
	
	assembler perform: #subAfromT withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 41 209])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testSubDoubleX1fromX0 [
	
	assembler perform: #subDoubleX1fromX0 withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[242 15 92 193])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testSubFromRconstant__2 [
	
	assembler perform: #subFromRconstant: withArguments: #(2).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 232 2])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testSubFromRconstant__4 [
	
	assembler perform: #subFromRconstant: withArguments: #(4).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 232 4])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testSubFromRconstant__8 [
	
	assembler perform: #subFromRconstant: withArguments: #(8).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 232 8])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testSubFromRconstant__m2 [
	
	assembler perform: #subFromRconstant: withArguments: #(-2).
	self 
		assert: (assembler bytes)
		equals: (#[72 131 232 254])
	
]

{ #category : #'tests - generated' }
AMD64CodeGeneratorTest >> testSubTslotsToSP [
	
	assembler subTslotsToSP.
	self 
		assert: (assembler bytes)
		equals: (#[72 247 217 72 141 36 204 72 247 217])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testTestRintegerBit [
	
	assembler perform: #testRintegerBit withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[168 1])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testTestRwithR [
	
	assembler perform: #testRwithR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 133 192])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testWriteTslots [
	
	assembler perform: #writeTslots withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[243 72 171])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testXorAwithR [
	
	assembler perform: #xorAwithR withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 49 194])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testXorFPwithFP [
	
	assembler perform: #xorFPwithFP withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 49 237])
	
]

{ #category : #'tests - generated 2' }
AMD64CodeGeneratorTest >> testXorRwithA [
	
	assembler perform: #xorRwithA withArguments: #().
	self 
		assert: (assembler bytes)
		equals: (#[72 49 208])
	
]
