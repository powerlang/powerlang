Class {
	#name : #ScriptSegmentBuilder,
	#superclass : #KernelSegmentBuilder,
	#instVars : [
		'script'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'instance creation' }
ScriptSegmentBuilder class >> compileScriptFile: script [
	self compileScriptFile: script writeTo: (script asFileReference withExtension:'bsl')
	
	
]

{ #category : #'instance creation' }
ScriptSegmentBuilder class >> compileScriptFile: script writeTo: bsl [
	(self forScriptFile: script) build; writeToFile: bsl
	
	
	
]

{ #category : #'instance creation' }
ScriptSegmentBuilder class >> forScript: readStream [
	| script scriptPkg |
	
	script := RGEnvironment new.
	scriptPkg := script ensurePackageNamed: #Script. 
	(TonelParser parseStream: readStream) 
		do:[:e|e ensureRingDefinitionIn: script package: scriptPkg].
	script behaviorsDo: [ :beh | beh superclass == beh ifTrue: [ beh superclass: nil. ] ].			
	script clean.
	^self new script: script
]

{ #category : #'instance creation' }
ScriptSegmentBuilder class >> forScriptFile: file [
	^file asFileReference readStreamDo:[ :s | self forScript: s ]
]

{ #category : #building }
ScriptSegmentBuilder >> build [
	| scriptDef |	
	scriptDef := self scriptDef. 
	
	(scriptDef >> #evaluate) isNil ifTrue:[
		self assert: (scriptDef >> #start) notNil.
		scriptDef compile: 'evaluate ^self start' classified: #startup
	].
	super genesis.
]

{ #category : #utilities }
ScriptSegmentBuilder >> findClassDef: name [
	"Return a class definition (as RGBehavior) for class
	 with given name or nil (if not found in definitions)"
	
	^(definition at: name) ifNil:[script at: name]
]

{ #category : #'building-private' }
ScriptSegmentBuilder >> fixHierarchy [
	| scriptDef |
	
	super fixHierarchy.
	scriptDef := self scriptDef.
	self fixHierarchyIn: (classDef2ClassObjMap at: scriptDef) def: scriptDef.

]

{ #category : #building }
ScriptSegmentBuilder >> genesis [
	self shouldNotImplement. "Use #build instead"
]

{ #category : #'building-private' }
ScriptSegmentBuilder >> makeClasses [
	super makeClasses.
	self makeClassIfNotAlready: self scriptDef name
]

{ #category : #building }
ScriptSegmentBuilder >> makeLoadAction [
	^self makeInstanceOf: self scriptDef name
]

{ #category : #accesing }
ScriptSegmentBuilder >> script: anRGEnvironment [
	script := anRGEnvironment.
	script clean.
]

{ #category : #accesing }
ScriptSegmentBuilder >> scriptDef [
	| behaviors |
	
	self assert: script notNil.
	behaviors := OrderedCollection new.
	script behaviorsDo: [ :each | (each isMetaclass not and:[each package name == #Script]) ifTrue: [ behaviors add: each ] ].
	self assert: behaviors size == 1.
	^behaviors first
]
