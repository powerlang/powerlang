Author useAuthor: 'PowerSmalltalkLoader' during: [ 
	| repo | 
	Metacello new
	  baseline: 'PetitParser';
	  repository: 'github://moosetechnology/PetitParser/src';
	  load.

	[
	IceCredentialsProvider useCustomSsh: false.
	repo := IceRepositoryCreator new
		url: 'git@github.com:shingarov/petrich.git';
		cloneRepository] on: IceCloneLocationAlreadyExists 
			do: [:ex | 
				repo := IceRepositoryCreator new 
					location: 'pharo-local/iceberg/shingarov/petrich' asFileReference;
					addLocalRepository
	].
	
    repo register.
	repo checkoutBranch: 'master'.
	{'GDB-Primitives'. 'GDB-RSP'. 'GDB-TAJ'. 'GDB-Tests'. 'GDB-UI'. 
	 'Petrich-Core'. 'Petrich-CoreExtensions'. 'Petrich-DUI'. 
	 'Petrich-InstructionSelector'. 'Petrich-Parsing'. 'Petrich-Pig'.
	 'Petrich-Tests' } do: [ :name |
	 	(repo packageNamed: name) load ]
].


(Smalltalk saveAs: (Smalltalk imageDirectory asFileReference) / 'PST-Petrich' )
    ifFalse: [ Smalltalk snapshot: false andQuit: true ].



