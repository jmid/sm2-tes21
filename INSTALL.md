Installation instructions:
==========================

You need to install
 - [OCaml](https://ocaml.org/) and the [qcheck library](https://github.com/c-cube/qcheck) (use OCaml's package manager [OPAM](https://opam.ocaml.org/) for this)
 - an editor (VS Code) to program/edit OCaml code.

The below instructions are adapted from [Scott F. Smith's instructions](http://pl.cs.jhu.edu/pl/ocaml/).


For Linux and Mac:
------------------

 0. Install dependencies (m4, make, gcc):
    ```
     sudo apt-get install m4 make gcc
    ```
    (on Ubuntu/Debian Linux and Windows Subsystem for Linux)

    On Mac: install the three dependencies via macports or homebrew.

 1. Install `opam`. See [the OPAM install page](https://opam.ocaml.org/doc/Install.html) for
    instructions. Depending on which method you use you may then need to
    run some terminal commands. For a recent Ubuntu (and Ubuntu under Windows Subsystem for Linux) you can run:
    ```
     sudo apt-get install unzip
     sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)
    ```
    For older Ubuntu versions you can run:
    ```
     sudo add-apt-repository ppa:avsm/ppa
     sudo apt update
     sudo apt install opam
    ```

 2. `opam init`                   to initialize OPAM;
 
    `opam init --disable-sandboxing`    (on Windows)

    Answer `y` to allowing `opam` to add changes to your `.profile`.
    Also answer `y` to setting up an init-script hook.

 3. `opam switch create 4.11.1`       to build OCaml version 4.11.1;

    If step 2 above finishes with `installed ocaml.4.11.1` you can skip this step.

 4. `eval $(opam env)`        to let the shell know where the OPAM files are.

 5. Once you have the basics installed, run the following command to
    install additional necessary packages for the class: 

    ```
     opam install qcheck ocamlfind ocamlbuild merlin ocp-indent user-setup utop
    ```


For Windows:
------------

On Windows 10:
  Install  MSFT [Bash on Windows](https://docs.microsoft.com/en-us/windows/wsl/about)
  and afterwards follow the Linux Ubuntu install instructions to get opam.
  (Windows 10 only for this unfortunately and it may have some incompatibilities).

For older Windows versions:
  - Install a virtual machine with Linux [as explained here](http://pl.cs.jhu.edu/pl/ocaml/)
    and install OCaml on that or
  - Try this installer: https://fdopen.github.io/opam-repository-mingw/installation/
  - Last resort: call Jan


Checking your OCaml and QCheck installation:
--------------------------------------------

To ensure that OCaml and QCheck is properly installed:

1. check that you can use the arrow keys and backspace in the OCaml
   toplevel if you run the command `utop`

2. check that in the `utop` toplevel
  ```
    #list;;
  ```
   lists package `qcheck` (version: 0.5 or above)

   For the `ocaml` toplevel you need to write two lines:
  ```
    #use "topfind";;
    #list;;
  ```

3. check that you can run QCheck from the toplevel following [this screencast](https://asciinema.org/a/226227)
   and from utop with [this screencast](https://asciinema.org/a/226259)

4. check that you can build a QCheck test with ocamlbuild
   following [this screencast](https://asciinema.org/a/226228)

   the code for the latter is also available here: https://github.com/jmid/qcheck-example



Installing VS Code:
-------------------

- Install VS Code https://code.visualstudio.com/

- Install the 'OCaml and Reason IDE' extension to get syntax
  highlighting, type information, etc: from the 'View' menu select
  'Extensions, then type in OCaml and this extension will show up;
  install it. You can also easily run an ocaml shell from within
  VSCode, just open it up from the 'Terminal' menu and type `ocaml` or
  `utop` into the terminal.

- On Windows 10: install the 'remote WSL' extension as described here:

    https://code.visualstudio.com/docs/remote/wsl

  This way, VS Code can find `ocamlfind` and `ocamlmerlin` in the
  Windows Subsystem for Linux without further configuration.

  Enabling a `bash` Terminal rather than a 'Powershell' will also let
  you run `ocaml` or `utop` from within VS Code.


Troubleshooting: If VS Code complains that it cannot find the `QCheck`
module on either Windows, Mac, or Linux, create a file called `.merlin`
with the content

```
PKG qcheck
```
This way, you inform the language server `merlin` of the `qcheck` dependency.
