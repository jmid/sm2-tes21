Lecture 11: Sanitizers and Fuzz Testing
=======================================

Sanitizer links:

- ASan: https://github.com/google/sanitizers/wiki/AddressSanitizer  http://clang.llvm.org/docs/AddressSanitizer.html  
- MSan: https://github.com/google/sanitizers/wiki/MemorySanitizer  http://clang.llvm.org/docs/MemorySanitizer.html  
- UBSan: http://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html

Fuzzer links:

- fuzz (the original): http://pages.cs.wisc.edu/~bart/fuzz/fuzz.html
  * [Miller-Fredriksen-So:CACM90 fuzz paper](ftp://ftp.cs.wisc.edu/paradyn/technical_papers/fuzz.pdf)
- AFL: http://lcamtuf.coredump.cx/afl/ 
  * QuickStart guide: http://lcamtuf.coredump.cx/afl/QuickStartGuide.txt  
  * README: http://lcamtuf.coredump.cx/afl/README.txt  
  * Technical description: http://lcamtuf.coredump.cx/afl/technical_details.txt
- libFuzzer: https://llvm.org/docs/LibFuzzer.html  
- OSS-Fuzz: https://github.com/google/oss-fuzz/  
- Crowbar for OCaml: https://github.com/stedolan/crowbar  
  * [short 2-page workshop paper](https://ocaml.org/meetings/ocaml/2017/extended-abstract__2017__stephen-dolan_mindy-preston__testing-with-crowbar.pdf)


Exercises:

1. Try out the sanitizers

   - Install clang:
     ``` 
      sudo apt-get install clang       (Ubuntu and Ubuntu in a Windows subsystem)
     ```
     On Mac `clang` is probably already available via XCode.
   
   - Compile the examples ([example1.c](example1.c), [example2.c](example2.c), ...) with, e.g., ASan and run them.
   
   - Confirm that the sanitizer detects problems.


2. Try AFL on a program of your choice, e.g., the program `ministat`:  

   - Install AFL.  

     On Ubuntu and Windows Subsystem for Linux:
     ```
      sudo apt-get update
      sudo apt-get install afl
     ```

     On Mac: `sudo brew install afl-fuzz` (Homebrew) or  `sudo port install afl` (MacPorts)  

   - Download `ministat` from [here](https://github.com/thorduri/ministat) or some other C/C++ program
     you would like to fuzz test.

   - Compile the program with `afl-clang` or `afl-gcc` (or `afl-clang++` or `afl-g++`)  

   - Confirm that you can run the produced executable  

   - Run AFL  

     The two example inputs (our corpus) are available in [ministat-corpus](ministat-corpus)  


3. Try libFuzzer on [test-libfuzzer.c](test-libfuzzer.c)

   Confirm that you can reproduce the error

   Mac folks:

   * First check which `clang` compiler you have:
     ```
      $ clang --version
      Apple LLVM version 9.0.0 (clang-900.0.39.2)
      Target: x86_64-apple-darwin16.7.0
      Thread model: posix
      InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
     ```
     If it says `Apple LLVM` like above you will need to install another `clang` via Homebrew or MacPorts

   * `sudo brew install llvm` (Homebrew) or  `sudo port install clang-9.0` (MacPorts)  

   * Afterwards I can the call this other `clang` compiler as `clang-mp-9.0` (on MacPorts)
 
     For Homebrew: Info for setting up your PATH to pick up the new `clang`:  https://embeddedartistry.com/blog/2017/02/24/installing-llvm-clang-on-osx/


4. In any remaining time: Work on your course projects
