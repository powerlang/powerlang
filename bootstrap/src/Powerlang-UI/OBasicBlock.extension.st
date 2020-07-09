Extension { #name : #OBasicBlock }

{ #category : #'*Powerlang-UI' }
OBasicBlock >> gtInspectorViewIn: composite [
	<gtInspectorPresentationOrder: -10>
	composite roassal3
		title: 'View';
		initializeCanvas: [ BasicBlockVisualization new root: self; addBlocks; canvas ]
]
