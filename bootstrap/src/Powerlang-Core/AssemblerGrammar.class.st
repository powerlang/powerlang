"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #AssemblerGrammar,
	#superclass : #PPCompositeParser,
	#category : #'Powerlang-Core-Assembler-Parser'
}

{ #category : #accessing }
AssemblerGrammar >> base [
	^self reg
]

{ #category : #private }
AssemblerGrammar >> comma [
	^$, asParser trim
]

{ #category : #accessing }
AssemblerGrammar >> constant [
	^self hex / self decimal
]

{ #category : #accessing }
AssemblerGrammar >> decimal [
	^#digit asParser plus flatten
]

{ #category : #accessing }
AssemblerGrammar >> displacement [
	^self operator , self constant
]

{ #category : #accessing }
AssemblerGrammar >> hex [
	^'0x' asParser , #hex asParser plus
]

{ #category : #private }
AssemblerGrammar >> imm [
	^self immH / self immD
]

{ #category : #private }
AssemblerGrammar >> immD [
	^self sign , self decimal
]

{ #category : #private }
AssemblerGrammar >> immH [
	^self hex
]

{ #category : #accessing }
AssemblerGrammar >> index [
	^self sum , self reg
]

{ #category : #accessing }
AssemblerGrammar >> instruction [
	^self prefix optional , self mnemonic trim , self operands
]

{ #category : #accessing }
AssemblerGrammar >> label [
	^(self labelName , $: asParser) flatten
]

{ #category : #accessing }
AssemblerGrammar >> labelName [
	^($@ asParser , #word asParser plus) flatten
]

{ #category : #accessing }
AssemblerGrammar >> memory [
	^self memorySize optional , $[ asParser trim
		, (self segment , ':' asParser) optional
		, self sib
		, $] asParser trim
]

{ #category : #accessing }
AssemblerGrammar >> memorySize [
	^'qword' asParser / 'dword' asParser / 'word' asParser / 'bword' asParser
		/ 'byte' asParser
		/ 'xmmword' asParser
		/ 'ymmword' asParser
		/ 'zmmword' asParser
		, 'ptr' asParser trim optional
]

{ #category : #accessing }
AssemblerGrammar >> mnemonic [
	^(#letter asParser , (#letter asParser / #digit asParser) star) flatten
]

{ #category : #accessing }
AssemblerGrammar >> mul [
	^$* asParser trim flatten
]

{ #category : #accessing }
AssemblerGrammar >> operand [
	^self memory / self reg / self imm / self labelName
]

{ #category : #accessing }
AssemblerGrammar >> operands [
	^(self operands3 / self operands2 / self operands1) optional
]

{ #category : #accessing }
AssemblerGrammar >> operands1 [
	^self operand
]

{ #category : #accessing }
AssemblerGrammar >> operands2 [
	^self operand , self comma , self operand
]

{ #category : #accessing }
AssemblerGrammar >> operands3 [
	^self operand , self comma , self operand , self comma , self operand
]

{ #category : #accessing }
AssemblerGrammar >> operator [
	^($+ asParser / $- asParser) trim
]

{ #category : #accessing }
AssemblerGrammar >> prefix [
	^PPChoiceParser
		withAll: (#(	'lock' 'repne' 'repnz' 'repe' 'repz'  'rep')
			collect: [:name | name asParser trim])
]

{ #category : #accessing }
AssemblerGrammar >> reg [
	^(PPChoiceParser
		withAll: ((Registers asArray sortBy: [:a :b | a name size > b name size])
			collect: [:r | r name asParser])) flatten
]

{ #category : #accessing }
AssemblerGrammar >> scale [
	^self mul , ($1 asParser / $2 asParser / $4 asParser / $8 asParser)
]

{ #category : #accessing }
AssemblerGrammar >> segment [
	^'cs' asParser / 'ds' asParser / 'ss' asParser / 'es' asParser
		/ 'fs' asParser
		/ 'gs' asParser
]

{ #category : #private }
AssemblerGrammar >> separator [
	^#blank asParser star flatten
]

{ #category : #accessing }
AssemblerGrammar >> sib [
	^self sib1 / self sib3 / self sib2
]

{ #category : #accessing }
AssemblerGrammar >> sib1 [
	^self displacement / self constant
]

{ #category : #accessing }
AssemblerGrammar >> sib2 [
	^self base , self index optional , self scale optional
		, self displacement optional
]

{ #category : #accessing }
AssemblerGrammar >> sib3 [
	^self reg , self scale , self displacement
]

{ #category : #accessing }
AssemblerGrammar >> sign [
	^($+ asParser / $- asParser) trim optional
]

{ #category : #accessing }
AssemblerGrammar >> start [
	^self label / self instruction
		, (#blank asParser plus flatten , (self label / self instruction)) star
]

{ #category : #accessing }
AssemblerGrammar >> sum [
	^$+ asParser trim flatten
]
