Class {
	#name : #SMethodNode,
	#superclass : #SScriptNode,
	#instVars : [
		'selector',
		'pragma'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SMethodNode >> acceptVisitor: visitor [
	^visitor visitMethod: self
]

{ #category : #parsing }
SMethodNode >> buildMethod [
	| cm encoder astcodes |
	cm := self methodClass withAll: self literals.
	cm
		blockCount: compiler blockCount;
		tempCount: scope stackSize;
		argumentCount: arguments size;
		environmentCount: scope environmentSize;
		capturesSelf: scope capturesSelf;
		hasEnvironment: self needsEnvironment;
		hasFrame: self needsFrame;
		selector: self selector;
		source: compiler sourceCode;
		classBinding: scope classBinding.
	cm blocks do: [ :block | block method: cm ].
	encoder := AstcodeEncoder new method: cm.
	astcodes := self acceptVisitor: encoder.
	^ cm astcodes: astcodes
]

{ #category : #parsing }
SMethodNode >> captureHome [
	
]

{ #category : #accessing }
SMethodNode >> compiler: aSmalltalkCompiler [
	super compiler: aSmalltalkCompiler.
	scope := aSmalltalkCompiler newScope script: self.
	pragma := aSmalltalkCompiler pragmaNode
]

{ #category : #private }
SMethodNode >> environmentIndexOf: aParseNode [
	^nil
]

{ #category : #inquiries }
SMethodNode >> header [
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
SMethodNode >> isHeadless [
	^selector isNil
]

{ #category : #testing }
SMethodNode >> isMethod [
	^true
]

{ #category : #parsing }
SMethodNode >> literals [
	| literals v l binding |
	literals := OrderedCollection new.
	self
		nodesDo: [ :n | 
			n isLiteral
				ifTrue: [ v := n value.
					v isSmallInteger
						ifFalse: [ literals add: v ] ].
			n isMessageNode
				ifTrue: [ literals add: n symbol ].
			n isBraceNode
				ifTrue: [ n isLiteral
						ifTrue: [ self halt ]
						ifFalse: [ binding := scope resolve: #Array. literals add: binding association ] ].
			(n isIdentifier
				and: [ l := n binding literal.
					l notNil ])
				ifTrue: [ literals add: l ].
			(n isBlockNode andNot: [ n isInlined ])
				ifTrue: [ literals add: n buildBlock ] ].
	^ literals removeDuplicates
]

{ #category : #parsing }
SMethodNode >> methodClass [
	^SCompiledMethod
]

{ #category : #testing }
SMethodNode >> needsEnvironment [
	^scope environmentSize > 0
		or: [children anySatisfy: [:block | block usesHome]]
]

{ #category : #testing }
SMethodNode >> needsFrame [
	scope stackSize > 0 ifTrue: [ ^ true ].
	arguments size > 16 ifTrue: [ ^ true ].
	compiler hasSends ifTrue: [ ^ true ].
	compiler hasBlocks ifTrue: [ ^ true ].
	^ false
]

{ #category : #enumerating }
SMethodNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	(aBoolean and: [selector notNil]) ifTrue: [aBlock evaluateWith: selector]
]

{ #category : #accessing }
SMethodNode >> pragma [
	^pragma
]

{ #category : #accessing }
SMethodNode >> pragma: anObject [
	pragma := anObject
]

{ #category : #accessing }
SMethodNode >> realScript [
	^self
]

{ #category : #accessing }
SMethodNode >> selector [
	^selector value
]

{ #category : #accessing }
SMethodNode >> selector: aSelectorNode [
	selector := aSelectorNode
]

{ #category : #accessing }
SMethodNode >> selectorNode [
	^selector
]
