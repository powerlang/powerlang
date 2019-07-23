Class {
	#name : #HeapModel,
	#superclass : #ComposablePresenter,
	#instVars : [
		'names',
		'storage',
		'label',
		'contents'
	],
	#category : #'Powerlang-UI'
}

{ #category : #specs }
HeapModel class >> defaultSpec [
	^ SpecColumnLayout composed
		add: #label height: self toolbarHeight;
		add: #contents;
		yourself
]

{ #category : #specs }
HeapModel class >> forSimulatedPst [
	<example>
	| kernel stream builder writer runtime labels |
	kernel := ProjectSpec new
		name: 'kernel';
		path: '../src/kernel' asFileReference;
		load.
	builder := SmalltalkKernel new
		project: kernel;
		build.
	stream := #[] writeStream.
	writer := ImageSegmentWriter new
		stream: stream;
		objects: builder objects;
		write.
	runtime := Runtime forSimulatedPst: writer image.
	runtime bridge findNilObject.
	runtime loadShapesFrom: kernel.
	labels := Dictionary new.
	builder classes
		do: [ :class | 
			| classname offset ibehavior cbehavior |
			classname := (class at: 'name') asString.
			offset := writer offsetOf: class.
			ibehavior := class at: 'instanceBehavior'.
			ibehavior := writer offsetOf: ibehavior.
			cbehavior := writer offsetOf: class behavior.
			labels
				at: offset put: classname;
				at: ibehavior put: classname , '_b';
				at: cbehavior put: classname , '_class_b' ].
	self new
		addLabels: labels;
		storage: writer image;
		openWithSpec;
		updateContents
]

{ #category : #accessing }
HeapModel >> addLabels: aDictionary [
	names addAll: aDictionary
]

{ #category : #accessing }
HeapModel >> analyzedText [
	| stream text font |
	stream := storage readStream.
	text := '' writeStream.
	[ stream atEnd ]
		whileFalse: [ | bytes address |
			address := stream position.
			bytes := stream next: 8.
			self describe: bytes at: address into: text].
	font := TextFontReference
		toFont:
			(LogicalFont
				familyName: 'Source Code Pro'
				pointSize: StandardFonts defaultFont pointSize).
	^ text contents asText addAttribute: font
]

{ #category : #accessing }
HeapModel >> contents [
^contents
]

{ #category : #accessing }
HeapModel >> describe: bytes at: address into: aStream [
	| slot addr value |
	slot := bytes readStream uint64le.
	names
		at: address
		ifPresent: [ :name | 
			aStream
				nextPutAll: '    ';
				nextPutAll: name;
				nextPut: $:;
				cr ].
	addr := address printStringHex padLeftTo: 16 with: $0.
	value := names
		at: slot
		ifPresent: [ :name | name padLeftTo: 16 ]
		ifAbsent: [ slot printStringHex padLeftTo: 16 ].
	aStream
		nextPutAll: addr;
		tab: 2;
		nextPutAll: value;
		nextPutAll: ' | '.
	bytes
		do: [ :byte | 
			| char |
			char := (byte between: 32 and: 126)
				ifTrue: [ byte asCharacter ]
				ifFalse: [ $. ].
			aStream nextPut: char ].
	aStream
		nextPutAll: ' |';
		cr
]

{ #category : #accessing }
HeapModel >> extent [
	^ 700 @ 800
]

{ #category : #accessing }
HeapModel >> initialize [
	super initialize.
	names := Dictionary new.
	names at: 16r10 put: 'nil'; at: 16r18 put: 'true'; at: 16r20 put: 'false'
]

{ #category : #accessing }
HeapModel >> initializeWidgets [
	contents := self instantiate: TextPresenter.
	contents
		aboutToStyle: true;
		beForText.
	label := self newLabel.
	label label: 'Memory'.
	self focusOrder add: contents
]

{ #category : #accessing }
HeapModel >> label [
	^ label
]

{ #category : #accessing }
HeapModel >> names: aDictionary [
	names := aDictionary
]

{ #category : #accessing }
HeapModel >> storage: bytes [
	storage := bytes
]

{ #category : #accessing }
HeapModel >> title [
	^'Heap inspector'
]

{ #category : #'event handling' }
HeapModel >> updateContents [
	contents text: self analyzedText
]
