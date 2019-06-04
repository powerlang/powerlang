Author useAuthor: 'PowerSmalltalkLoader' during: [
    | repo |
    "Based on the same file from the pharo-vm project"
    IceCredentialsProvider useCustomSsh: false.
    repo := IceRepositoryCreator  new
                location: '..' asFileReference;
                createRepository.

    repo register.
    (repo packageNamed: 'Powerlang-PST') load.
].

SystemWindow closeTopWindow. "close HelpBrowser"
GTPlayground openContents: '
| kernel |
kernel := ProjectSpec new
    name: ''kernel'';
    path: ''../pst/kernel'' asFileReference;
    load.

ProjectBrowser new project: kernel; openWithSpec.
Debugger new openWithSpec.
'.

(Smalltalk saveAs: (Smalltalk imageDirectory asFileReference) / 'bootstrap' )
    ifFalse: [ Smalltalk snapshot: false andQuit: true ].
