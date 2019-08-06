"
## Browsing PST code

Load PST smalltalk code.
"

    repo := TonelRepository new directory: '../pst' asFileReference.
    env := repo  asRingEnvironmentWith: #(kernel).
    env clean.

"
Open a browser on PST code
"

    env browse.

"

## Other unsorted / uncommented  expressions

"

    Debugger new openWithSpec.

"
"