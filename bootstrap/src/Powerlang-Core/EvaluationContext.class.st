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
	| closure s i type env arg |
	closure := system newClosureFor: anSBlock compiledCode.
	s := anSBlock capturedVariables readStream.
	i := 1.
	[ s atEnd ]
		whileFalse: [ type := s next.
			type = Self
				ifTrue: [ closure at: i put: self self ].
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
	^system methodClassBinding: self method
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
EvaluationContext >> instanceVarAt: index [
	^ system instanceVarOf: self self at: index
]

{ #category : #visiting }
EvaluationContext >> instanceVarAt: index put: value [
	^ system instanceVarOf: self self at: index put: value
]

{ #category : #services }
EvaluationContext >> loadAssociationValue: anObject [
	^system loadAssociationValue: anObject
]

{ #category : #visiting }
EvaluationContext >> method [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> method: anSCompiledMethod [
	^ self subclassResponsibility
]

{ #category : #visiting }
EvaluationContext >> methodArguments [
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
EvaluationContext >> self [
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
EvaluationContext >> staticBindingFor: symbol inModule: module [
	|  namespace assoc |
	namespace := system moduleNamespace: module.
	assoc := system lookupAssociationFor: symbol in: namespace.
	assoc ifNil: [ self error: 'unbound variable: ' , symbol asString ].
	^ SAssociationBinding new association: assoc
]

{ #category : #accessing }
EvaluationContext >> staticBindingForCvar: aSymbol [
	| species cvars namespace nilObj |
	species := system methodClassBinding: self method.
	nilObj := system nil.
	[ cvars := system speciesClassVariables: species.
	cvars = nilObj
		ifFalse: [ 1 to: cvars size do: [ :i | 
				namespace := cvars at: i.
				(system lookupAssociationFor: aSymbol in: namespace)
					ifNotNil: [ :assoc | ^ SAssociationBinding new association: assoc ] ] ].
	species := system speciesSuperclass: species.
	species = nilObj ] whileFalse.
	^ nil
]

{ #category : #accessing }
EvaluationContext >> staticBindingForIvar: aSymbol [
	| ivar |
	ivar := system staticBindingForIvar: aSymbol in: self self.
	^ ivar > 0
		ifTrue: [ SInstVarBinding new index: ivar ]
]

{ #category : #accessing }
EvaluationContext >> staticBindingForMvar: symbol [
	| species module |
	species := system methodClassBinding: self method.
	module := system speciesModule: species.
	^ self staticBindingFor: symbol inModule: module
]

{ #category : #services }
EvaluationContext >> staticBindingForNested: name [ 
	| module |
	module := self staticBindingFor: (name at: 1).
	^self staticBindingFor: (name at: 2) inModule: module
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
