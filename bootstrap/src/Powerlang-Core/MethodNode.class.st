Class {
	#name : #MethodNode,
	#superclass : #ScriptNode,
	#instVars : [
		'selector',
		'pragma'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #visiting }
MethodNode >> acceptVisitor: visitor [
	^visitor visitMethod: self
]

{ #category : #parsing }
MethodNode >> buildMethod [
	| cm encoder astcodes |
	cm := self methodClass withAll: self literals.
	cm
		blockCount: compiler blockCount;
		tempCount: scope stackSize;
		argumentCount: arguments size;
		environmentCount: scope environmentSize;
		selector: self selector;
		source: compiler sourceCode;
		classBinding: scope classBinding.
	cm blocks do: [ :block | block method: cm ].
	encoder := AstcodeEncoder new method: cm.
	astcodes := self acceptVisitor: encoder.
	^cm astcodes: astcodes
]

{ #category : #parsing }
MethodNode >> captureHome [
	
]

{ #category : #accessing }
MethodNode >> compiler: aSmalltalkCompiler [
	super compiler: aSmalltalkCompiler.
	scope := aSmalltalkCompiler newScope script: self.
	pragma := aSmalltalkCompiler pragmaNode
]

{ #category : #private }
MethodNode >> environmentIndexOf: aParseNode [
	^nil
]

{ #category : #inquiries }
MethodNode >> header [
	"
	(Object >> #printOn:) ast header
	"
	| interval |
	interval := selector stretch.
	arguments notEmpty
		ifTrue: [interval := interval start thru: arguments last stretch end].
	^compiler sourceCode copyFrom: interval start to: interval end
]

{ #category : #testing }
MethodNode >> isHeadless [
	^selector isNil
]

{ #category : #testing }
MethodNode >> isMethod [
	^true
]

{ #category : #parsing }
MethodNode >> literals [
	| literals v l |
	literals := OrderedCollection new.
	self nodesDo: [ :n |
		n isLiteral ifTrue: [ v := n value. v isSmallInteger ifFalse: [ literals add: v] ].
		n isMessageNode ifTrue: [ literals add: n symbol].
		(n isIdentifier and: [ l := n binding literal. l notNil ])
			ifTrue: [literals add: l].
		(n isBlockNode andNot: [n isInlined]) ifTrue: [ literals add: n buildBlock. ]
	].
	
	^literals removeDuplicates
]

{ #category : #parsing }
MethodNode >> methodClass [
	^PCompiledMethod
]

{ #category : #testing }
MethodNode >> needsEnvironment [
	^scope environmentSize > 0
		or: [children anySatisfy: [:block | block usesHome]]
]

{ #category : #enumerating }
MethodNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	(aBoolean and: [selector notNil]) ifTrue: [aBlock evaluateWith: selector]
]

{ #category : #accessing }
MethodNode >> pragma [
	^pragma
]

{ #category : #accessing }
MethodNode >> pragma: anObject [
	pragma := anObject
]

{ #category : #accessing }
MethodNode >> realScript [
	^self
]

{ #category : #accessing }
MethodNode >> selector [
	^selector value
]

{ #category : #accessing }
MethodNode >> selector: aSelectorNode [
	selector := aSelectorNode
]

{ #category : #accessing }
MethodNode >> selectorNode [
	^selector
]
