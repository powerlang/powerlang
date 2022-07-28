Class {
	#name : #JSTranspiler,
	#superclass : #Object,
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
			PowertalkInterpreter.
			PowertalkIterativeInterpreter.
			PowertalkIterativeStackedInterpreter}
		, SBinding withAllSubclasses , SExpression withAllSubclasses
]

{ #category : #'as yet unclassified' }
JSTranspiler class >> transpilePowerlangInterpreter [
	| transpiler |
	transpiler := self new.
	self powerlangInterpreterClasses do: [ :c | transpiler transpileClass: c ]
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
	filename := self outputDirectory / (aClass name , '.js').
	filename
		writeStreamDo: [ :s | 
			s truncate.
			ws := ZnNewLineWriterStream on: s.
			self transpileClass: aClass into: ws ]
]

{ #category : #transpiling }
JSTranspiler >> transpileClass: aClass into: ws [
	self transpileClassDefinition: aClass into: ws.
	aClass methods
		reject: [ :m | m selector beginsWith: #print ]
		thenDo: [ :m |
			JSMethodTranspiler new
				method: m;
				stream: ws;
				transpile ].
	ws
		nextPutAll: '}';
		cr;
		cr;
		nextPutAll: 'export default ';
		nextPutAll: aClass name;
		cr
]

{ #category : #transpiling }
JSTranspiler >> transpileClassDefinition: aClass into: ws [
	| supername |
	supername := aClass superclass name.
	supername != 'Object'
		ifTrue: [ ws
				cr;
				nextPutAll: 'import ';
				nextPutAll: supername;
				nextPutAll: ' from ''./';
				nextPutAll: supername;
				nextPutAll: '.js'';';
				cr ].
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
