Class {
	#name : #ScriptScopeTest,
	#superclass : #TestCase,
	#category : #'Powerlang-SCompiler-Tests'
}

{ #category : #private }
ScriptScopeTest >> assert: binding isEnvArg: name at: index [
	self
		assert: binding isArgument;
		assert: binding name = name;
		assert: binding index = index;
		assert: binding isInArray;
		assert: binding environmentIndex = nil
]

{ #category : #private }
ScriptScopeTest >> assert: binding
isEnvTemp: name
at: environment
index: index [
	self
		assert: binding isTemporary;
		assert: binding isInArray;
		assert: binding name = name;
		assert: binding index = index;
		assert: binding environment = environment
]

{ #category : #private }
ScriptScopeTest >> assert: binding isStackArg: name at: index [
	self
		assert: binding isArgument;
		assert: binding isInStack;
		assert: binding name = name;
		assert: binding index = index
]

{ #category : #private }
ScriptScopeTest >> assert: binding isStackInlineArg: name at: index [
	self
		assert: binding isArgument;
		assert: binding isInStack;
		assert: binding name = name;
		assert: binding index = index;
		assert: binding environmentObject class = InlinedArgEnvironment
]

{ #category : #private }
ScriptScopeTest >> assert: binding isStackTemp: name at: index [
	self
		assert: binding isTemporary;
		assert: binding isInStack;
		assert: binding name = name;
		assert: binding index = index
]

{ #category : #private }
ScriptScopeTest >> checkArgs: names in: scope [
	names withIndexDo: [:name :index | | binding |
		binding := scope resolve: name.
		self
			assert: binding isArgument;
			assert: binding name = name;
			assert: binding index = index]
]

{ #category : #private }
ScriptScopeTest >> checkClassVarsOf: aSpecies in: scope [
	aSpecies withAllSuperclasses do: [:c | 
		c classPool associationsDo: [:assoc | | name binding |
			name := assoc key.
			binding := scope resolve: name.
			self
				assert: binding isClassVariable;
				assert: binding name = name;
				assert: binding association == assoc]]
]

{ #category : #private }
ScriptScopeTest >> checkClosureEnvTemps: names in: scope at: environment [
	| offset |
	offset := scope environmentSizeUpToCapturedArguments.
	names withIndexDo: [:name :index | | binding |
		binding := scope resolve: name.
		self
			assert: binding isTemporary;
			assert: binding isInArray;
			assert: binding name = name;
			assert: binding index = (index + offset);
			assert: binding environment = environment]
]

{ #category : #private }
ScriptScopeTest >> checkEnvTemps: names in: scope at: environment [
	names withIndexDo: [:name :index | | binding |
		binding := scope resolve: name.
		self
			assert: binding isTemporary;
			assert: binding isInArray;
			assert: binding name = name;
			assert: binding index = index;
			assert: binding environment = environment]
]

{ #category : #private }
ScriptScopeTest >> checkInstVarsOf: aSpecies in: scope [
	aSpecies allInstVarNames withIndexDo: [:name :i | | binding |
		binding := scope resolve: name.
		self
			assert: binding isInstVar;
			assert: binding name = name;
			assert: binding index = i]
]

{ #category : #private }
ScriptScopeTest >> checkTemps: names in: scope [
	names withIndexDo: [:name :index | | binding |
		binding := scope resolve: name.
		self assert: binding isStackTemp: name at: index]
]

{ #category : #private }
ScriptScopeTest >> compile: aString [
	^self compile: aString in: UndefinedObject
]

{ #category : #private }
ScriptScopeTest >> compile: aString in: aClass [
	^SCompiler parse: aString in: aClass
]

{ #category : #private }
ScriptScopeTest >> precondition: aBoolean [
	self assert: aBoolean description: 'Precondition for this test is not met'
]

{ #category : #private }
ScriptScopeTest >> scopeFor: aSpecies [
	^MethodScope new
]

{ #category : #private }
ScriptScopeTest >> test010resolveClass [
	| binding |
	binding := SCompiler new smalltalkCompiler methodNode scope resolve: 'Point'.
	self
		assert: binding isDynamic;
		assert: binding name = #Point
]

{ #category : #private }
ScriptScopeTest >> test010resolveSelf [
	| scope receiver sup |
	scope := self scopeFor: Object.
	receiver := scope resolve: 'self'.
	sup := scope resolve: 'super'.
	self
		assert: receiver isSelf;
		assert: receiver name = 'self';
		assert: sup isSuper;
		assert: sup name = 'super'
]

{ #category : #private }
ScriptScopeTest >> test011resolveUnknownGlobal [
	| binding point |
	self precondition: (Smalltalk includesKey: 'Foo678' existingSymbol) not.
	binding := MethodScope new resolve: 'Foo678'.
	self assert: binding isDynamic.
	point := self scopeFor: Point.
	binding := point resolve: 'Foo678'.
	self assert: binding isDynamic
]

{ #category : #private }
ScriptScopeTest >> test020resolveMethodArguments [
	| scope |
	scope := self scopeFor: Point.
	scope
		defineArgument: 'arg1';
		defineArgument: 'arg2';
		positionDefinedLocals.
	self checkArgs: #('arg1' 'arg2') in: scope
]

{ #category : #private }
ScriptScopeTest >> test021resolveMethodTemporaries [
	| scope |
	scope := self scopeFor: Point.
	scope defineTemporary: 't1'; defineTemporary: 't2'; positionDefinedLocals.
	self checkTemps: #('t1' 't2') in: scope
]

{ #category : #private }
ScriptScopeTest >> test030resolveNestedTemporaryConflictingWithIvar [
	| ast b3 x |
	ast := self compile: 'foo  [ | x | [[x]] ]' in: Point.
	b3 := ast children first children first children first.
	x := b3 statements first binding.
	self
		assert: x
		isEnvTemp: 'x'
		at: 1
		index: 1
]

{ #category : #private }
ScriptScopeTest >> test040declareMethodArguments [
	| ast scope |
	ast := self compile: 'foo: anArg bar: anotherArg' in: Point.
	scope := ast scope.
	self checkArgs: #('anArg' 'anotherArg') in: scope
]

{ #category : #private }
ScriptScopeTest >> test041declareMethodTemporaries [
	| ast scope |
	ast := self compile: 'foo | t1 t2 | ' in: Point.
	scope := ast scope.
	self checkTemps: #('t1' 't2') in: scope
]

{ #category : #private }
ScriptScopeTest >> test042declareMethodTempsWithArgs [
	| ast scope |
	ast := self compile: 'foo: arg1 bar: arg2 | t1 t2 | ' in: Point.
	scope := ast scope.
	self
		checkArgs: #('arg1' 'arg2') in: scope;
		checkTemps: #('t1' 't2') in: scope
]

{ #category : #private }
ScriptScopeTest >> test050useMethodTemps [
	| ast scope t1 t2 |
	ast := self compile: 'foo | t1 t2 | t1. t2' in: Point.
	scope := ast scope.
	t1 := ast statements first binding.
	t2 := ast statements second binding.
	self
		checkTemps: #('t1' 't2') in: scope;
		assert: t1 isTemporary;
		assert: t1 isInStack;
		assert: t1 name = 't1';
		assert: t1 index = 1;
		assert: t2 isTemporary;
		assert: t2 isInStack;
		assert: t2 name = 't2';
		assert: t2 index = 2
]

{ #category : #private }
ScriptScopeTest >> test051useMethodArgs [
	| ast scope a1 a2 |
	ast := self compile: 'foo: a1 bar: a2 a1. a2' in: Point.
	scope := ast scope.
	a1 := ast statements first binding.
	a2 := ast statements second binding.
	self
		checkArgs: #('a1' 'a2') in: scope;
		assert: a1 isArgument;
		assert: a1 isInStack;
		assert: a1 name = 'a1';
		assert: a1 index = 1;
		assert: a2 isArgument;
		assert: a2 isInStack;
		assert: a2 name = 'a2';
		assert: a2 index = 2
]

{ #category : #private }
ScriptScopeTest >> test052useMethodTempsAndArgs [
	| ast scope a1 a2 t1 t2 |
	ast := self compile: 'foo: a1 bar: a2 | t1 t2 | t1. t2. a1. a2' in: Point.
	scope := ast scope.
	t1 := ast statements first binding.
	t2 := ast statements second binding.
	a1 := ast statements third binding.
	a2 := ast statements fourth binding.
	self
		checkArgs: #('a1' 'a2') in: scope;
		checkTemps: #('t1' 't2') in: scope;
		assert: t1 isTemporary;
		assert: t1 isInStack;
		assert: t1 name = 't1';
		assert: t1 index = 1;
		assert: t2 isTemporary;
		assert: t2 isInStack;
		assert: t2 name = 't2';
		assert: t2 index = 2;
		assert: a1 isArgument;
		assert: a1 isInStack;
		assert: a1 name = 'a1';
		assert: a1 index = 1;
		assert: a2 isArgument;
		assert: a2 isInStack;
		assert: a2 name = 'a2';
		assert: a2 index = 2
]

{ #category : #private }
ScriptScopeTest >> test053useBlockArgs [
	| ast block scope a1 a2 |
	ast := self compile: 'foo [:a1 :a2 | a1. a2]' in: Point.
	block := ast children first.
	scope := block scope.
	a1 := block statements first binding.
	a2 := block statements second binding.
	self
		checkArgs: #('a1' 'a2') in: scope;
		assert: a1 isStackArg: 'a1' at: 1;
		assert: a2 isStackArg: 'a2' at: 2
]

{ #category : #private }
ScriptScopeTest >> test053useSiblingBlockArgs [
	| ast block1 block2 a1 a2 |
	ast := self compile: 'foo [:a1 | a1]. [:a2 | a2]' in: Point.
	block1 := ast children first.
	block2 := ast children second.
	a1 := block1 statements first binding.
	a2 := block2 statements first binding.
	self
		checkArgs: #('a1') in: block1 scope;
		checkArgs: #('a2') in: block2 scope;
		assert: a1 isStackArg: 'a1' at: 1;
		assert: a2 isStackArg: 'a2' at: 1
]

{ #category : #private }
ScriptScopeTest >> test054useBlockTemps [
	| ast block scope t1 t2 |
	ast := self compile: 'foo [| t1 t2 | t1. t2]' in: Point.
	block := ast children first.
	scope := block scope.
	t1 := block statements first binding.
	t2 := block statements second binding.
	self
		checkTemps: #('t1' 't2') in: scope;
		assert: t1 isStackTemp: 't1' at: 1;
		assert: t2 isStackTemp: 't2' at: 2
]

{ #category : #private }
ScriptScopeTest >> test055methodUseGlobal [
	| ast global |
	ast := self compile: 'foo Collection' in: Point.
	global := ast statements first binding.
	self
		assert: global isDynamic;
		assert: global name = #Collection
]

{ #category : #private }
ScriptScopeTest >> test060useNestedMethodArgs [
	| ast block ma1 ma2 ba1 ba2 |
	ast := self compile: 'foo: a1 bar: a2  a1. a2. [a1. a2]' in: Object.
	block := ast children first.
	ma1 := ast statements first binding.
	ma2 := ast statements second binding.
	ba1 := block statements first binding.
	ba2 := block statements second binding.
	self
		checkArgs: #('a1' 'a2') in: ast scope;
		assert: ma1 isStackArg: 'a1' at: 1;
		assert: ma2 isStackArg: 'a2' at: 2;
		assert: ba1 isEnvArg: 'a1' at: 1;
		assert: ba2 isEnvArg: 'a2' at: 2
]

{ #category : #private }
ScriptScopeTest >> test061useNestedMethodSiblingBlockTemps [
	| ast block1 block2 b1t1 b2t2 |
	ast := self compile: 'foo | t1 t2 | [t1]. [t2]' in: Object.
	block1 := ast children first.
	block2 := ast children second.
	b1t1 := block1 statements first binding.
	b2t2 := block2 statements first binding.
	self
		checkEnvTemps: #('t1' 't2') in: ast scope at: nil;
		assert: b1t1
			isEnvTemp: 't1'
			at: 1
			index: 1;
		assert: b2t2
			isEnvTemp: 't2'
			at: 1
			index: 2
]

{ #category : #private }
ScriptScopeTest >> test061useNestedMethodTemps [
	| ast block bt1 bt2 |
	ast := self compile: 'foo | t1 t2 | [t1. t2]' in: Object.
	block := ast children first.
	bt1 := block statements first binding.
	bt2 := block statements second binding.
	self
		checkEnvTemps: #('t1' 't2') in: ast scope at: nil;
		assert: bt1
			isEnvTemp: 't1'
			at: 1
			index: 1;
		assert: bt2
			isEnvTemp: 't2'
			at: 1
			index: 2
]

{ #category : #private }
ScriptScopeTest >> test062useNestedBlockArgs [
	| ast block1 block2 b1a1 b1a2 b2a1 b2a2 |
	ast := self compile: 'foo [:a1 :a2 | [a1. a2] ]' in: Object.
	block1 := ast children first.
	block2 := block1 children first.
	b1a1 := block1 scope resolve: 'a1'.
	b1a2 := block1 scope resolve: 'a2'.
	b2a1 := block2 statements first binding.
	b2a2 := block2 statements second binding.
	self
		checkArgs: #('a1' 'a2') in: block1 scope;
		assert: b1a1 isStackArg: 'a1' at: 1;
		assert: b1a2 isStackArg: 'a2' at: 2;
		assert: b2a1 isEnvArg: 'a1' at: 1;
		assert: b2a2 isEnvArg: 'a2' at: 2
]

{ #category : #private }
ScriptScopeTest >> test063useNestedBlockTemps [
	| ast block1 block2 b2t1 b2t2 |
	ast := self compile: 'foo [| t1 t2 | [t1. t2]]' in: Object.
	block1 := ast children first.
	block2 := block1 children first.
	b2t1 := block2 statements first binding.
	b2t2 := block2 statements second binding.
	self
		checkClosureEnvTemps: #('t1' 't2') in: block1 scope at: nil;
		assert: b2t1
			isEnvTemp: 't1'
			at: 1
			index: 1;
		assert: b2t2
			isEnvTemp: 't2'
			at: 1
			index: 2
]

{ #category : #private }
ScriptScopeTest >> test064useSiblingBlocksNestedTemps [
	| ast block1 block2 block3 b2t1 b3t2 |
	ast := self compile: 'foo [| t1 t2 | [t1]. [t2]]' in: Object.
	block1 := ast children first.
	block2 := block1 children first.
	block3 := block1 children second.
	b2t1 := block2 statements first binding.
	b3t2 := block3 statements first binding.
	self
		checkClosureEnvTemps: #('t1' 't2') in: block1 scope at: nil;
		assert: b2t1
			isEnvTemp: 't1'
			at: 1
			index: 1;
		assert: b3t2
			isEnvTemp: 't2'
			at: 1
			index: 2
]

{ #category : #private }
ScriptScopeTest >> test065useNestedBlockAndMethodTemps [
	| ast block1 block2 b2t1 b2t2 |
	ast := self compile: 'foo | t1 | [| t2 | [t1. t2]]' in: Object.
	block1 := ast children first.
	block2 := block1 children first.
	b2t1 := block2 statements first binding.
	b2t2 := block2 statements second binding.
	self
		checkEnvTemps: #('t1') in: ast scope at: nil;
		checkClosureEnvTemps: #('t2') in: block1 scope at: nil;
		assert: b2t1
			isEnvTemp: 't1'
			at: 1
			index: 1;
		assert: b2t2
			isEnvTemp: 't2'
			at: 2
			index: 2
]

{ #category : #private }
ScriptScopeTest >> test070useDoublyNestedMethodArgs [
	| ast block1 block2 b1a1 b1a2 b2a1 b2a2 |
	ast := self compile: 'foo: a1 bar: a2  [[a1. a2]]' in: Object.
	block1 := ast children first.
	block2 := block1 children first.
	b1a1 := block1 scope resolve: 'a1'.
	b1a2 := block1 scope resolve: 'a2'.
	b2a1 := block2 statements first binding.
	b2a2 := block2 statements second binding.
	self
		checkArgs: #('a1' 'a2') in: ast scope;
		assert: b1a1 isEnvArg: 'a1' at: 1;
		assert: b1a2 isEnvArg: 'a2' at: 2;
		assert: b2a1 isEnvArg: 'a1' at: 1;
		assert: b2a2 isEnvArg: 'a2' at: 2
]

{ #category : #private }
ScriptScopeTest >> test071useDoublyNestedMethodTemps [
	| ast block1 block2 b1t1 b1t2 b2t1 b2t2 |
	ast := self compile: 'foo | t1 t2 | [[t1. t2]]' in: Object.
	block1 := ast children first.
	block2 := block1 children first.
	b1t1 := block1 scope resolve: 't1'.
	b1t2 := block1 scope resolve: 't2'.
	b2t1 := block2 statements first binding.
	b2t2 := block2 statements second binding.
	self
		checkEnvTemps: #('t1' 't2') in: ast scope at: nil;
		assert: b1t1
			isEnvTemp: 't1'
			at: 1
			index: 1;
		assert: b1t2
			isEnvTemp: 't2'
			at: 1
			index: 2;
		assert: b2t1
			isEnvTemp: 't1'
			at: 1
			index: 1;
		assert: b2t2
			isEnvTemp: 't2'
			at: 1
			index: 2
]

{ #category : #private }
ScriptScopeTest >> test075useDoublyNestedMethodArgsWithTemps [
	| ast block1 block2 b1a1 b1a2 b1t1 b1t2 b2a1 b2a2 b2t1 b2t2 |
	ast := self
		compile: 'foo: a1 bar: a2 | t1 | [| t2 | [a1. a2. t1. t2]]'
		in: Object.
	block1 := ast children first.
	block2 := block1 children first.
	b1a1 := block1 scope resolve: 'a1'.
	b1a2 := block1 scope resolve: 'a2'.
	b1t1 := block1 scope resolve: 't1'.
	b1t2 := block1 scope resolve: 't2'.
	b2a1 := block2 statements first binding.
	b2a2 := block2 statements second binding.
	b2t1 := block2 statements third binding.
	b2t2 := block2 statements fourth binding.
	self
		checkArgs: #('a1' 'a2') in: ast scope;
		assert: b1a1 isEnvArg: 'a1' at: 2;
		assert: b1a2 isEnvArg: 'a2' at: 3;
		assert: b1t2
			isEnvTemp: 't2'
			at: nil
			index: 4;
		assert: b1t1
			isEnvTemp: 't1'
			at: 1
			index: 1;
		assert: b2t1
			isEnvTemp: 't1'
			at: 1
			index: 1;
		assert: b2t2
			isEnvTemp: 't2'
			at: 2
			index: 4;
		assert: b2a1 isEnvArg: 'a1' at: 3;
		assert: b2a2 isEnvArg: 'a2' at: 4
]

{ #category : #private }
ScriptScopeTest >> test080captureSelf [
	| ast block receiver |
	ast := self compile: 'foo [self]' in: Object.
	block := ast children first.
	receiver := block statements first binding.
	self
		assert: receiver isSelf;
		assert: ast environmentSize = 0;
		assert: block scope capturesSelf;
		assert: block environmentSize equals: 1;
		assert: block scope home == nil
]

{ #category : #private }
ScriptScopeTest >> test090useNonLocalReturn [
	| ast block |
	ast := self compile: 'foo [^1]' in: Object.
	block := ast children first.
	self
		assert: ast environmentSize = 0;
		assert: ast needsEnvironment;
		assert: block environmentSize = 1;
		assert: block scope home == ast
]

{ #category : #private }
ScriptScopeTest >> test091nonLocalReturnSelf [
	| ast block |
	ast := self compile: 'foo [^self]' in: Object.
	block := ast children first.
	self
		assert: ast environmentSize = 0;
		assert: ast needsEnvironment;
		assert: block environmentSize = 2;
		assert: block scope home == ast
]

{ #category : #private }
ScriptScopeTest >> test100inlineUseMethodArgs [
	| ast block a1 a2 |
	ast := self compile: 'foo: a1 bar: a2  1 ifTrue: [a1. a2]' in: Point.
	block := ast children first.
	a1 := block statements first binding.
	a2 := block statements second binding.
	self
		checkArgs: #('a1' 'a2') in: ast scope;
		assert: a1 isStackArg: 'a1' at: 1;
		assert: a2 isStackArg: 'a2' at: 2
]

{ #category : #private }
ScriptScopeTest >> test101inlineUseMethodTemps [
	| ast t1 t2 block |
	ast := self compile: 'foo | t1 t2 | 1 ifTrue: [t1. t2]' in: Point.
	block := ast children first.
	t1 := block statements first binding.
	t2 := block statements second binding.
	self
		checkTemps: #('t1' 't2') in: ast scope;
		assert: t1 isStackTemp: 't1' at: 1;
		assert: t2 isStackTemp: 't2' at: 2
]

{ #category : #private }
ScriptScopeTest >> test102inlineUseMethodArgsAndTemps [
	| ast block a1 a2 t1 t2 |
	ast := self
		compile: 'foo: a1 bar: a2  | t1 t2 | 1 ifTrue: [a1. a2. t1. t2]'
		in: Point.
	block := ast children first.
	a1 := block statements first binding.
	a2 := block statements second binding.
	t1 := block statements third binding.
	t2 := block statements fourth binding.
	self
		checkArgs: #('a1' 'a2') in: ast scope;
		assert: a1 isStackArg: 'a1' at: 1;
		assert: a2 isStackArg: 'a2' at: 2;
		assert: t1 isStackTemp: 't1' at: 1;
		assert: t2 isStackTemp: 't2' at: 2
]

{ #category : #private }
ScriptScopeTest >> test110inlineUseMixedMethodTemps [
	| ast t1 t2 block |
	ast := self compile: 'foo | t1 | 1 ifTrue: [ | t2 | t1. t2]' in: Point.
	block := ast children first.
	t1 := block statements first binding.
	t2 := block statements second binding.
	self
		checkTemps: #('t1') in: ast scope;
		assert: t1 isStackTemp: 't1' at: 1;
		assert: t2 isStackTemp: 't2' at: 2
]

{ #category : #private }
ScriptScopeTest >> test120inlineEnvironmentTemp [
	| ast block1 block2 mt1 mt2 b1t1 b1t2 b2t2 |
	ast := self
		compile: 'foo | t1 | 1 ifTrue: [ | t2 | t1. [t2]]'
		in: Point.
	block1 := ast children first.
	block2 := block1 children first.
	mt1 := ast scope resolve: 't1'.
	mt2 := ast scope resolve: 't2'.
	b1t1 := block1 statements first binding.
	b1t2 := block1 scope resolve: 't2'.
	b2t2 := block2 scope resolve: 't2'.
	self
		checkTemps: #('t1') in: ast scope;
		assert: mt2 isDynamic;
		assert: mt1 isStackTemp: 't1' at: 1;
		assert: b1t1 isStackTemp: 't1' at: 1;
		assert: b1t2
			isEnvTemp: 't2'
			at: nil
			index: 1;
		assert: b2t2
			isEnvTemp: 't2'
			at: 1
			index: 1;
		assert: ast scope environmentSize = 1
]

{ #category : #private }
ScriptScopeTest >> test130inlineBlockArg [
	| ast block a1 |
	ast := self compile: 'foo  1 ifNotNil: [:a1 | 1 ]' in: Point.
	block := ast children first.
	a1 := block scope resolve: 'a1'.
	self assert: a1 isStackInlineArg: 'a1' at: 1
]

{ #category : #private }
ScriptScopeTest >> test131inlineBlockArgWithTemp [
	| ast block t1 a1 |
	ast := self compile: 'foo | t1 | 1 ifNotNil: [:a1 | 1 ]' in: Point.
	block := ast children first.
	t1 := ast scope resolve: 't1'.
	a1 := block scope resolve: 'a1'.
	self
		assert: t1 isStackTemp: 't1' at: 1;
		assert: a1 isStackInlineArg: 'a1' at: 2
]

{ #category : #private }
ScriptScopeTest >> test132inlineBlockArgWithTemps [
	| ast block t1 a1 t2 |
	ast := self compile: 'foo | t1 | 1 ifNotNil: [:a1 | | t2 | 1 ]' in: Point.
	block := ast children first.
	t1 := ast scope resolve: 't1'.
	a1 := block scope resolve: 'a1'.
	t2 := block scope resolve: 't2'.
	self
		assert: t1 isStackTemp: 't1' at: 1;
		assert: t2 isStackTemp: 't2' at: 2;
		assert: a1 isStackInlineArg: 'a1' at: 3
]

{ #category : #private }
ScriptScopeTest >> test133inlineBlockArgWithEnvTemps [
	| ast block1 mt1 b1a1 b1t2 |
	ast := self
		compile: 'foo | t1 | 1 ifNotNil: [:a1 | | t2 | 1. [t2] ]'
		in: Point.
	block1 := ast children first.
	mt1 := ast scope resolve: 't1'.
	b1a1 := block1 scope resolve: 'a1'.
	b1t2 := block1 scope resolve: 't2'.
	self
		assert: mt1 isStackTemp: 't1' at: 1;
		assert: b1t2 isEnvTemp: 't2' at: nil index: 1;
		assert: b1a1 isStackInlineArg: 'a1' at: 2
]

{ #category : #private }
ScriptScopeTest >> test134inlineBlockArgNestedAccess [
	| ast block1 block2 b1a1 b2a1 |
	ast := self compile: 'foo  1 ifNotNil: [:a1 | [a1] ]' in: Point.
	block1 := ast children first.
	block2 := block1 children first.
	b1a1 := block1 scope resolve: 'a1'.
	b2a1 := block2 scope resolve: 'a1'.
	self
		assert: b1a1 isEnvArg: 'a1' at: 1;
		assert: b2a1 isEnvArg: 'a1' at: 1
]

{ #category : #private }
ScriptScopeTest >> test135inlineBlockWithArgInRealBlockCaptured [
	| ast block1 block2 block3 b2a1 b3a1 |
	"Args of inlined blocks can go to the stack of the real block, unless captured. Because the
	 capture bytecode doesn't have a slot type for 'copy from stack temps' (it has capture from
	 stack in 	 args zone, capture the current env, and capture a value in the current env)"
	ast := self compile: 'foo  [1 ifNotNil: [:a1 | [a1] ]]' in: Point.
	block1 := ast children first.
	block2 := block1 children first.
	block3 := block2 children first.
	b2a1 := block2 scope resolve: 'a1'.
	b3a1 := block3 scope resolve: 'a1'.
	self
		assert: b2a1 isEnvArg: 'a1' at: 1;
		assert: b3a1 isEnvArg: 'a1' at: 1
]

{ #category : #private }
ScriptScopeTest >> test136inlineBlockWithArgCapturedByInlinedBlock [
	| ast block1 block2 b1a1 b2a1 |
	ast := self compile: 'foo 1 ifNotNil: [:a1 | a1. 2 ifTrue: [a1]]' in: Point.
	block1 := ast children first.
	block2 := block1 children first.
	b1a1 := block1 scope resolve: 'a1'.
	b2a1 := block2 scope resolve: 'a1'.
	self
		assert: b1a1 isStackInlineArg: 'a1' at: 1;
		assert: b2a1 isStackInlineArg: 'a1' at: 1
]

{ #category : #private }
ScriptScopeTest >> test137inlineBlockWithArgCapturedByInlinedBlockInRealBlock [
	| ast block1 block2 block3 b1a1 b3a1 |
	ast := self
		compile: 'foo 1 ifNotNil: [:a1 | [2 ifTrue: [a1]]]'
		in: Point.
	block1 := ast children first.
	block2 := block1 children first.
	block3 := block2 children first.
	b1a1 := block1 scope resolve: 'a1'.
	b3a1 := block3 scope resolve: 'a1'.
	self
		assert: b1a1 isEnvArg: 'a1' at: 1;
		assert: b3a1 isEnvArg: 'a1' at: 1
]

{ #category : #private }
ScriptScopeTest >> test138blockWithInlinedBlockWithTempCaptured [
	| ast block1 block2 block3 b2t1 b3t1 block |
	ast := self compile: 'foo [true ifTrue: [| t1 | [t1]]]' in: Point.
	block1 := ast children first.
	block2 := block1 children first.
	block3 := block2 children first.
	b2t1 := block2 scope resolve: 't1'.
	b3t1 := block3 scope resolve: 't1'.
	self
		assert: b2t1
			isEnvTemp: 't1'
			at: nil
			index: 1;
		assert: b3t1
			isEnvTemp: 't1'
			at: 1
			index: 1
]

{ #category : #private }
ScriptScopeTest >> test140blockWithInlinedBlockHasEnv [
	| ast |
	ast := self compile: 'foo [true ifTrue: [^self]]'.
	self assert: ast needsEnvironment
]
