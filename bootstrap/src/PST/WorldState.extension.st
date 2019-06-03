Extension { #name : #WorldState }

{ #category : #'*PST' }
WorldState class >> pstClassBrowser [
	| kernel |
	kernel := ProjectSpec new
		name: 'kernel';
		path: '../src/kernel' asFileReference;
		load.
	ProjectBrowser new
		project: kernel;
		openWithSpec
]

{ #category : #'*PST' }
WorldState class >> pstDebug [
	Debugger new openWithSpec.

]

{ #category : #'*PST' }
WorldState class >> pstItemsOn: aBuilder [
	<worldMenu>
	(aBuilder item: #PST)
		label: 'PST';
		icon: ((self iconNamed: #smallObjects) scaledToSize: 16 @ 16);
		order: 0;
		with: [ (aBuilder item: #'Class Browser')
				target: self;
				selector: #pstClassBrowser;
				help: 'Open a class browser on PST source.';
				keyText: 'P';
				iconName: #configNew.
			(aBuilder item: #'Debug something...')
				target: self;
				selector: #pstDebug;
				help: 'Open a debugger to follow some code.';
				iconName: #smallDebug.
				(aBuilder item: #'PST playground')
				target: self;
				selector: #pstPlayground;
				help: 'Open a playground with PST goodies.';
				iconName: #image ]
]

{ #category : #'*PST' }
WorldState class >> pstPlayground [
	Playground new openWithSpec
]
