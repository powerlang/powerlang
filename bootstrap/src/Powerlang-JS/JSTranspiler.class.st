Class {
	#name : #JSTranspiler,
	#superclass : #Object,
	#instVars : [
		'transpilers'
	],
	#category : #'Powerlang-JS'
}

{ #category : #'as yet unclassified' }
JSTranspiler class >> powerlangInterpreterClasses [
	^ LMRObject withAllSubclasses
		,
			{LMRObjectHeader.
			EvaluationContext.
			StackedEvaluationContext.
			PowertalkRuntime.
			PowertalkLMR.
			SExpressionLinearizer.
			AstNodeTypes.
			AstBindingTypes.
			AstcodeDecoder.
			SCompiledBlockFlags.
			SCompiledMethodFlags.
			ClosureElementTypes.
			PowertalkInterpreter.
			PowertalkIterativeInterpreter.
			PowertalkIterativeStackedInterpreter} , SBinding withAllSubclasses
		, SExpression withAllSubclasses
]

{ #category : #'as yet unclassified' }
JSTranspiler class >> transpilePowerlangInterpreter [
	| transpiler |
	transpiler := self new.
	self powerlangInterpreterClasses do: [ :c | transpiler transpileClass: c ]
]

{ #category : #transpiling }
JSTranspiler >> classImports: aClass [
	| result |
	result := Set new.
	result add: aClass superclass name.
	result addAll: aClass sharedPoolNames.
	transpilers do: [ :t | result addAll: t imports ].
	#('Object' 'Map' 'Array' 'Function' 'ArgCount' 'TempCount' 'EnvCount' 'BlockArgCount' 'BlockEnvCount' 'BlockTempCount' 'BlockCapturesHome' 'BlockCapturesSelf')
		do: [ :name | result remove: name ifAbsent: nil ].
	^ result
]

{ #category : #'as yet unclassified' }
JSTranspiler >> outputDirectory [
	"
		self new outputDirectory path pathString
	"

	^ self rootDirectory / 'LMRjs' / 'interpreter'
]

{ #category : #'as yet unclassified' }
JSTranspiler >> rootDirectory [
	^ './specs/bee-dmr' asFileReference
]

{ #category : #transpiling }
JSTranspiler >> transpileClass: aClass [
	| filename ws |
	self transpileMethods: aClass methods.
	filename := self outputDirectory / (aClass name , '.js').
	filename
		writeStreamDo: [ :s | 
			s truncate.
			ws := ZnNewLineWriterStream on: s.
			self writeClass: aClass into: ws ]
]

{ #category : #transpiling }
JSTranspiler >> transpileMethods: methods [
	transpilers := methods asArray
		sort: [ :a :b | a selector < b selector ];
		reject: [ :m | m selector beginsWith: #print ]
			thenCollect: [ :m | 
			JSMethodTranspiler new
				method: m;
				transpile ].

]

{ #category : #transpiling }
JSTranspiler >> writeClass: aClass into: ws [
	| imports |
		aClass superclass == PSharedPool
		ifTrue: [ ^ self writeSharedPool: aClass into: ws ].

	imports := self classImports: aClass.
	imports asArray sort
		do: [ :name | 
			ws
				nextPutAll: 'import ';
				nextPutAll: name;
				nextPutAll: ' from ''./';
				nextPutAll: name;
				nextPutAll: '.js'';';
				cr ].
	ws cr.
	self
		writeClassDefinition: aClass into: ws;
		writeMethodsInto: ws.
	ws
		nextPutAll: '}';
		cr;
		cr;
		nextPutAll: 'export default ';
		nextPutAll: aClass name;
		cr
]

{ #category : #transpiling }
JSTranspiler >> writeClassDefinition: aClass into: ws [
	ws cr
		nextPutAll: 'let ';
		nextPutAll: aClass name;
		nextPutAll: ' = class '.
	aClass superclass != Object
		ifTrue: [ ws
				nextPutAll: 'extends ';
				nextPutAll: aClass superclass name ].
	ws
		nextPutAll: '{';
		cr
]

{ #category : #transpiling }
JSTranspiler >> writeMethodsInto: ws [
	transpilers do: [ :t | ws nextPutAll: t result ]
]

{ #category : #transpiling }
JSTranspiler >> writeSharePoolValue: value on: ws [
	value isInteger
		ifTrue: [ ^ ws nextPutAll: value printString ].
	value class = Stretch
		ifTrue: [ ^ ws
				nextPut: $(; nextPutAll: value start printString ; nextPutAll: ').thru(' ; nextPutAll: value end printString
						; nextPut: $) ].
	self ASSERT: false
]

{ #category : #transpiling }
JSTranspiler >> writeSharedPool: aClass into: ws [
	ws cr
		nextPutAll: 'let ';
		nextPutAll: aClass name;
		nextPutAll: ' = Object.freeze({';
		crtab: 1.
	self writeSharedPoolVars: aClass into: ws.
	ws
		nextPutAll: '});';
		cr;
		cr;
		nextPutAll: 'Object.assign(globalThis, ';
		nextPutAll: aClass name;
		nextPutAll: ');';
		cr;
		cr;
		nextPutAll: 'export default ';
		nextPutAll: aClass name;
		cr
]

{ #category : #transpiling }
JSTranspiler >> writeSharedPoolVars: aClass into: ws [
	| vars |
	vars := aClass classVariables.
	vars
		do: [ :assoc | 
			ws
				nextPutAll: assoc key;
				nextPutAll: ': '.
			self writeSharePoolValue: assoc value on: ws ]
		separatedBy: [ ws
				nextPutAll: ',';
				crtab: 1 ].
	ws cr
]
