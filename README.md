# Odin - Manipulating the keyboard input and output in Linux
A simple demonstration program of the technique.

## Description
This program reads the keyboard input and writes to the keyboard output. With this idea in mind, it will be possible to manipulate the keyboard input and output and make a spell checker, for English and Portuguese, to help dyslexic People. This in any program they use, that has a TextEditor Box or a editor area. The spell checking would start by a key combination and would terminate by the same key combination. Basically, dyslexic people change the order of the letters, and same press the keys that are near by the correct key (adjacent keys). The words can come from Hunspell, or from a database of words. Then we would apply the Prof. Petter Norvig algoritm for spell checking (from his personal site) with the modification that I have made in the past, for Portuguese, in other repo in C_Sharp.

## Original code
This program is a modified port of the program <br>
<br>
actkbd - A keyboard shortcut daemon <br>
[http://users.softlab.ntua.gr/~thkala/projects/actkbd/actkbd.html](http://users.softlab.ntua.gr/~thkala/projects/actkbd/actkbd.html) <br>
<br>
And has the same license as the original code.

## Running the program
``` bash
# You have to run the program has sudo - super user.

$ make
$ sudo ./linux_dyslexic_help.exe  
```

## Current status
This program is in development. It can read the keyboard input and write the keyboard output. It can write the word "batatas" when the key number one is pressed. But only writes 4 characters of complete press and releases appear, then the user has to press another key to see the rest of the keys sent to the output (program where is the focus). Currently I don't know why this is happening. I will try to came back at a latter time to fix this. 

## License
GNU GPL v2

## Have fun
Best regards, <br>
Joao Carvalho <br>
