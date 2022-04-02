Class {
	#name : #EvaluationContext,
	#superclass : #Object,
	#instVars : [
		'system'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #visiting }
EvaluationContext >> argumentAt: anInteger [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> argumentAt: anInteger in: environmentIndex [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> arguments [
	^ self subclassResponsibility
]

{ #category : #services }
EvaluationContext >> backtrace [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> captureClosure: anSBlock [
	| block closure s i type env arg |
	block := anSBlock compiledCode.
	closure := system newClosure: block environmentCount.
	closure
		block: block;
		astcodes: anSBlock;
		builder: self.
	s := anSBlock capturedVariables readStream.
	i := 1.
	[ s atEnd ]
		whileFalse: [ type := s next.
			type = Self
				ifTrue: [ closure at: i put: self receiver ].
			type = Environment
				ifTrue: [ closure at: i put: self environment ].
			type = EnvironmentValue
				ifTrue: [ env := self environment at: s next.
					closure at: i put: env ].
			type = LocalArgument
				ifTrue: [ arg := self argumentAt: s next.
					closure at: i put: arg ].
			i := i + 1 ].
	^ closure
]

{ #category : #services }
EvaluationContext >> classBinding [
	^ self method classBinding
]

{ #category : #visiting }
EvaluationContext >> environment [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> false [
	^ system false
]

{ #category : #visiting }
EvaluationContext >> firstArgument [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> fourthArgument [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> home [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> instanceVarAt: index [
	^ system instanceVarOf: self receiver at: index
]

{ #category : #visiting }
EvaluationContext >> instanceVarAt: index put: value [
	^ system instanceVarOf: self receiver at: index put: value
]

{ #category : #services }
EvaluationContext >> loadAssociationValue: anObject [
	^system loadAssociationValue: anObject
]

{ #category : #visiting }
EvaluationContext >> method: anSCompiledMethod [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> nil [
	^ system nil
]

{ #category : #printing }
EvaluationContext >> printOn: aStream [
 self backtrace
				do: [ :frame | 
					frame
						do: [ :elem | elem printOn: aStream ]
						separatedBy: [ aStream nextPutAll: '. ' ].
					aStream cr ]
]

{ #category : #visiting }
EvaluationContext >> receiver [
	^self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> secondArgument [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> stackTemporaryAt: index [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> stackTemporaryAt: index put: value [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> staticBindingFor: aSymbol [
	| symbol |
	symbol := system symbolFrom: aSymbol.
	(self staticBindingForIvar: symbol) ifNotNil: [ :b | ^ b ].
	(self staticBindingForCvar: symbol) ifNotNil: [ :b | ^ b ].
	^ self staticBindingForMvar: symbol
]

{ #category : #accessing }
EvaluationContext >> staticBindingForCvar: aSymbol [
	| species cvars class |
	species := system speciesFor: self receiver.
	[ cvars := species classVariables.
	cvars isNil
		ifFalse: [ cvars
				associationAt: aSymbol
				ifPresent: [ :assoc | ^ SAssociationBinding new association: assoc ].
			species localPools
				do: [ :pool | 
					pool
						associationAt: aSymbol
						ifPresent: [ :assoc | 
							class := pool isConstant
								ifTrue: [ SConstantPoolBinding ]
								ifFalse: [ SAssociationBinding ].
							^ class new association: assoc ] ] ].
	species := species superclass.
	species isNil ] whileFalse.
	^ nil
]

{ #category : #accessing }
EvaluationContext >> staticBindingForIvar: aSymbol [
	| ivar |
	ivar := self receiver allSlotNames indexOf: aSymbol.
	^ ivar > 0
		ifTrue: [ SInstVarBinding new index: ivar ]
]

{ #category : #accessing }
EvaluationContext >> staticBindingForMvar: aSymbol [
	| assoc class |
	class := system speciesFor: self receiver.
	assoc := class module namespace
		associationAt: aSymbol
		ifAbsent: [ self error: 'unbound variable: ' , aSymbol asString].
	^ SAssociationBinding new association: assoc
]

{ #category : #services }
EvaluationContext >> storeAssociation: association value: anObject [ 
	system storeAssociation: association value: anObject 
]

{ #category : #visiting }
EvaluationContext >> system: aPowertalkRuntime [
	system := aPowertalkRuntime
]

{ #category : #visiting }
EvaluationContext >> temporaryAt: index in: environmentIndex [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> temporaryAt: index in: environmentIndex put: value [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> thirdArgument [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> true [
	^ system true
]
