Author useAuthor: 'PowerSmalltalkLoader' during: [ 
	| myRepository |
	"Based on the same file from the pharo-vm project"
	IceCredentialsProvider useCustomSsh: false.
	myRepository := IceRepositoryCreator new
		url: 'git@github.com:melkyades/bootstrap-pharo.git';
		createRepository.
	
    myRepository register.
	myRepository checkoutBranch: 'master'.
	(myRepository packageNamed: 'PST') load.
].

SystemWindow closeTopWindow. "close HelpBrowser"
GTPlayground openContents: '
| kernel |
kernel := ProyectSpec new 
	name: ''kernel'';
	path: ''../src/kernel'' asFileReference;
	load.
	
ProjectBrowser new project: kernel; openWithSpec.
Debugger new openWithSpec.
'.

(Smalltalk saveAs: (Smalltalk imageDirectory asFileReference) / 'PST' )
    ifFalse: [ Smalltalk snapshot: false andQuit: true ].
