// Name:           Odin - Manipulating the keyboard input and output in Linux.
//
// Description:    This program reads the keyboard input and writes to the
//                 keyboard output.
//                 With this idea in mind, it will be possible to manipulate the
//                 keyboard input and output and make a spell checker, for
//                 English and Portuguese, to help dyslexic People. This in any
//                 program they use, that has a TextEditor Box or a editor area.
//                 The spell checking would start by a key combination and would
//                 terminate by the same key combination.
//                 Basically, dyslexic people change the order of the letters,
//                 and same press the keys that are near by the correct key 
//                 (adjacent keys).
//                 The words can come from Hunspell, or from a database of words.
//                 Then we would apply the Prof. Petter Norvig algoritm for spell
//                 checking with the modification that I have made in the past, 
//                 for Portuguese, in other repo in C_Sharp.
//
// Current status: This program is in development.
//                 It can read the keyboard input and write the keyboard output.
//                 It can write the word "batatas" when the key number one is
//                 pressed.
//                 But only writes 4 characters of complete press and releases
//                 appear, then the user has to press another key to see the rest
//                 of the keys sent to the ouput (program where is the focus).
//                 Currently I don't know why this is happening.
//                 I will try to came back at a latter time to fix this. 
//
// Date:           2023-11-23
// Autor:          João Carvalho
// License:        GNU GPL v2
//
// Original code:  This program is a modified port of the program:
//                 actkbd - A keyboard shortcut daemon
//                 http://users.softlab.ntua.gr/~thkala/projects/actkbd/actkbd.html
//                 And has the same license as the original code.
//

package linux_dislexic_helper

import "core:fmt"
import "core:strings"
import "core:os"
import "core:c/libc"


PROCFS   :: "/proc/"
HANDLERS :: "bus/input/handlers"
DEVICES  :: "bus/input/devices"
DEVNODE  :: "/dev/input/event"

// It can be other number in a diferent Linux computer.
DEVICE_PATHNAME :: "/dev/input/event0" 

// Event types 
INVALID :: 0
KEY     :: 1 << 0
REP     :: 1 << 1
REL     :: 1 << 2

// Event types
EV_SYN       :: 0x00
EV_KEY       :: 0x01
EV_REL       :: 0x02
EV_ABS       :: 0x03
EV_MSC       :: 0x04
EV_SW        :: 0x05
EV_LED       :: 0x11
EV_SND       :: 0x12
EV_REP       :: 0x14
EV_FF        :: 0x15
EV_PWR       :: 0x16
EV_FF_STATUS :: 0x17
EV_MAX       :: 0x1f
EV_CNT       :: EV_MAX + 1

// The max number of keys available on a keyboard.
KEY_MAX :: 0x2ff

MyErrors :: enum {
    // Return values 
    ok,
    usage,
    mem_err,
    host_fail,
    dev_fail,
    read_err,
    write_err,
    ev_err,
    conf_err,
    fork_err,
    int_err,
    pid_err,
    no_match,
    invalid, 
}


// The device node
// static char devnode[32];

// The device file pointer, used by glibc
device_handler_glibc : ^libc.FILE

// The device file pointer, used by the core library.
// This doesn't work to read the /dev/input/event0 file from the device driver
// in Linux kernel.
device_handler : os.Handle

key_names_ordered := [?]string{ 
    "Esc", 
    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
    "\\", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "'", "«", "BackSpace",
    "Tab", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "+", "´", "Enter",  
    /* "CapsLock", */ "a", "s", "d", "f", "g", "h", "j", "k", "l", "ç", "º", "~",
    "ShiftLeft", "<", "z", "x", "c", "v", "b", "n", "m", ",", ".", "-", "ShiftRight",
    "ControlLeft", /* "WindowsKeyLeft", */ "AltLeft", "Space", "AltRight", /* "WindowsKeyRight", */ "ControlRight",
    "ArrowUp", "ArrowLeft", "ArrowDown", "ArrowRight",
    /* Those are only the main keys with out the modifing keys*/
}


// This is Portuguese Layout PT_pt .
keyboard_map := map[int]string{
    // 30 = "CapsLock",
    58 = "CapsLock",
    1 = "Esc",
    59 = "F1",
    60 = "F2",
    61 = "F3",
    62 = "F4",
    63 = "F5",
    64 = "F6",
    65 = "F7",
    66 = "F8",
    67 = "F9",
    68 = "F10",
    87 = "F11",
    88 = "F12",
    41 = "\\",
    2 = "1",
    3 = "2",
    4 = "3",
    5 = "4",
    6 = "5",
    7 = "6",
    8 = "7",
    9 = "8",
    10 = "9",
    11 = "0",
    12 = "'",
    13 = "«",
    14 = "BackSpace",
    15 = "Tab",
    16 = "q",
    17 = "w",
    18 = "e",
    19 = "r",
    20 = "t",
    21 = "y",
    22 = "u",
    23 = "i",
    24 = "o",
    25 = "p",
    26 = "+",
    27 = "sinal_grave", /* "\´", */
    28 = "Enter",
    30 = "a",
    31 = "s",
    32 = "d",
    33 = "f",
    34 = "g",
    35 = "h",
    36 = "j",
    37 = "k",
    38 = "l",
    39 = "ç",
    40 = "º",
    43 = "~",
    42 = "ShiftLeft",
    86 = "<",
    44 = "z",
    45 = "x",
    46 = "c",
    47 = "v",
    48 = "b",
    49 = "n",
    50 = "m",
    51 = ",",
    52 = ".",
    53 = "-",
    54 = "ShiftRight",
    29 = "ControlLeft",
    56 = "AltLeft",
    57 = "Space",
    100 = "AltRight",
    97 = "ControlRight",
    103 = "ArrowUp",
    105 = "ArrowLeft",
    108 = "ArrowDown",
    106 = "ArrowRight",
    }

key_names_ordered_index : int = 0

// The builder string to write the key names map, to then make the keys map.
my_builder : strings.Builder

// This don't work to read the /dev/input/event0 file from the device driver
open_device :: proc ( ) -> MyErrors {
    // It can be other number in a diferent Linux computer.
    // device_pathname : string = "/dev/input/event0"

    device_handler, err := os.open( DEVICE_PATHNAME, os.O_APPEND )
    if err != os.ERROR_NONE {
        // handle error
        fmt.printf( "Error: could not open %v: %s\n", 
                    DEVICE_PATHNAME, libc.strerror( i32( err ) ) )
        return MyErrors.dev_fail
    }

    return MyErrors.ok
}

// This don't work to read the /dev/input/event0 file from the device driver
close_device :: proc ( ) -> MyErrors {
    os.close( device_handler )
    return MyErrors.ok
}

open_device_glibc :: proc ( ) -> MyErrors {
    // It can be other number in a diferent Linux computer.
    // device_pathname : string = "/dev/input/event0"

    device_handler_glibc = libc.fopen( DEVICE_PATHNAME, "a+" )
    if device_handler_glibc == nil {
        // handle error
        fmt.printf( "Error: could not open %v: %s\n", 
                    DEVICE_PATHNAME, libc.strerror( libc.errno()^ ) )
        return MyErrors.dev_fail
    }

    return MyErrors.ok
}

close_device_glibc :: proc ( ) -> MyErrors {
    libc.fclose( device_handler_glibc )
    return MyErrors.ok
}

Time :: struct #packed {
    tv_sec  : i64,
    tv_usec : i64,
}

InputEvent :: struct #packed {
    ev_time : Time,
    type    : u16,
    code    : u16,
    value   : i32,
}

get_key :: proc ( ) -> ( key : int, type: int, my_error : MyErrors ) {
    ev  : InputEvent = InputEvent{}
    // ret : uint
    err : os.Errno

    // fmt.printf("size_of( ev ) = %v\n", size_of( ev ) )

    for {
        // ret, err = os.read_ptr( device_handler, & ev, size_of( ev ) )

        ret := libc.fread( & ev, size_of( ev ), 1, device_handler_glibc )
        if ret < 1 {        
            fmt.printf( "Error: failed to read event from %s: %s\n", 
                       DEVICE_PATHNAME, libc.strerror( libc.errno()^ ) ) 
            key  = 0
            type = 0
            return key, type, MyErrors.read_err
        }

        // fmt.printf("ev.code: [%v]    ev.type: [%v]   ev.value: [%v] \n",
        //            ev.code, ev.type, ev.value )

        if ev.type == EV_KEY {
            break
        }
    }

    key = int( ev.code )

    switch ev.value {
        case 0:
            type = REL
        case 1:
            type = KEY
        case 2:
            type = REP
        case:
            type = INVALID
    }

    if key > KEY_MAX {
	    type = INVALID
    }

    if type == INVALID {
        fmt.printf("Error: invalid event read from %s: code = %v, value = %v",
                   DEVICE_PATHNAME, ev.code, ev.value)
	    return key, type, MyErrors.ev_err
    }

    return key, type, MyErrors.ok
}

send_key :: proc ( key : int, type : int ) -> MyErrors {
    ev     : InputEvent
    // ret    : int
    // err : os.Errno

    // Fill's with the current time.
    // gettimeofday( &ev.time, NULL );

    ev.type = EV_KEY
    ev.code = u16( key )

    switch type {
        case KEY:
            ev.value = 1
        case REL:
            ev.value = 0
        case REP:
            ev.value = 2
        
        case:
            return MyErrors.invalid
    }

    ret := libc.fwrite( & ev, size_of( ev ), 1, device_handler_glibc )
    if ret < 1 {
	    fmt.printf("Error: failed to send event to %s: %s",
                    DEVICE_PATHNAME, libc.strerror( libc.errno()^ ) ) 
	    return MyErrors.write_err
    }

    // ret = write(fd, &event, sizeof(event));
    // if(ret < sizeof(event)) {

    // os.flush( device_handler )
    // usleep( 10000 );

    return MyErrors.ok
}

process_keys :: proc () -> MyErrors {

    send_key_press_and_release :: proc ( key_p : int ) {
        send_key( key_p, KEY )
        send_key( key_p, REL )
    }

    fmt.printf("...inside process_key()\n")


    // my_builder = strings.builder_make()
    // defer strings.builder_destroy( & my_builder )

    for { 
    
        // fmt.printf("...get_key()\n")
        key, type, my_error := get_key()
        if my_error != MyErrors.ok {
            return my_error
        }
    
        // fmt.printf("Event: ")
    
        if type == KEY {

            key_str, ok := keyboard_map[ int( key ) ]
            if ok {
                fmt.printf( "\nEvent key pressed: [%v] : [%s]\n", key, key_str )
            } else {
                fmt.printf( "\nEvent key pressed: [%v]\n", key )
            }

            // To Write the map to the screen.

            // my_str := fmt.aprintf( "%v = \"%v\",\n", key, key_names_ordered[ key_names_ordered_index ])
            // strings.write_string( & my_builder, my_str )
            // delete( my_str )

            // // if used all the keys, then stop the program.
            // if key_names_ordered_index == len( key_names_ordered ) - 1 {
            //     fmt.printf( "\n\n\nkey_names_ordered_index == len( key_names_ordered ) - 1\n" )
            //     fmt.printf( "my_builder.String() = [%v]\n", strings.to_string( my_builder ) )
            //     return MyErrors.ok
            // }

            // key_names_ordered_index += 1
        } else {
            key_str, ok := keyboard_map[ int( key ) ]
            if ok {
                fmt.printf("Event key : [%d] : [%s]  - %s\n",
                    key, key_str, ( type == KEY ) ? "key": ( ( type == REP ) ? "rep":"rel" ) )
            } else {
                fmt.printf("Event key : [%d] - %s\n",
                    key, ( type == KEY ) ? "key": ( ( type == REP ) ? "rep":"rel" ) )

            }
        }

        // The key that will trigger the writting of the word "batatas".
        key_number_one : int = 2
    
        // The keys that will be pressed to write the word "batatas".
        key_b : int = 48
        key_a : int = 30
        key_t : int = 20
        key_s : int = 31
    
        
        if type == REL && key == key_number_one {
    
            // Press and release the keys to write the word "batatas".
            send_key_press_and_release( key_b )
            send_key_press_and_release( key_a )
            send_key_press_and_release( key_t )
            send_key_press_and_release( key_a )
            send_key_press_and_release( key_t )
            send_key_press_and_release( key_a )
            send_key_press_and_release( key_s )
        }

    } // end for
}

main :: proc () {
    fmt.printf("Manipulating the keyboard input inside Linux.\n\n")

    open_device_glibc()
    defer close_device_glibc()
    
    process_keys()
}




// ----------------------------------------------------------------------------

/*
#define PROCFS "/proc/"
#define HANDLERS "bus/input/handlers"
#define DEVICES "bus/input/devices"
#define DEVNODE "/dev/input/event"


// The device node
static char devnode[32];

// The device file pointer
static FILE *dev;


// #include <regex.h>
// #include <sys/ioctl.h>

int init_dev() {
    FILE *fp = NULL;
    int ret;
    unsigned int u0, u1;
    regex_t preg;
    regmatch_t pmatch[4];

    maxkey = KEY_MAX;

    fp = fopen(PROCFS HANDLERS, "r");
    if (fp == NULL) {
	lprintf("Error: could not open " PROCFS HANDLERS ": %s\n", strerror(errno));
	return HOSTFAIL;
    }
    do {
	ret = fscanf(fp, "N: Number=%u Name=evdev Minor=%u", &u0, &u1);
	fscanf(fp, "%*s\n");
    } while ((!feof(fp)) && (ret < 2));
    if (ret < 2) {
	lprintf("Error: event interface not available\n");
	return HOSTFAIL;
    }
    if (verbose > 1)
	lprintf("Event interface present (handler %u)\n", u0);
    fclose(fp);

    /* Skip auto-detection when the device has been specified */
    if (device)
	return OK;

    fp = fopen(PROCFS DEVICES, "r");
    if (fp == NULL) {
	lprintf("Error: could not open " PROCFS DEVICES ": %s\n", strerror(errno));
	return HOSTFAIL;
    }

    /* Compile the regular expression and scan for it */
    ret = -1;
    regcomp(&preg, "^H: Handlers=(.* )?kbd (.* )?event([0-9]+)", REG_EXTENDED);
    do {
	char l[128] = "";
	void *str = fgets(l, 128, fp);
	if (str == NULL)
	    break;
	ret = regexec(&preg, l, 4, pmatch, 0);
	if (ret == 0) {
	    l[pmatch[3].rm_eo] = '\0';
	    ret = sscanf(l + pmatch[3].rm_so, "%u", &u0);
	} else {
	    ret = -1;
	}
    } while ((!feof(fp)) && (ret < 1));
    regfree(&preg);

    if (ret < 1) {
	lprintf("Error: could not detect a usable keyboard device\n");
	return HOSTFAIL;
    }
    if (verbose > 1)
	lprintf("Detected a usable keyboard device (event%u)\n", u0);

    fclose(fp);
    sprintf(devnode, DEVNODE "%u", u0);
    device = devnode;

    return OK;
}

*/


/*

// char ev_buf[8192];  // for example, 8K buffer

int open_dev() {
    dev = fopen(device, "a+");
    if (dev == NULL) {
	printf("Error: could not open %s: %s\n", device, strerror(errno));
	return DEVFAIL;
    }

    // NOTE(jnc) - Let's try a bigger buffer to see if the limit of 8 injected
    //             output caracteres is lifted?
    //             R: It didn't work. The limit is still 8.    
    // setvbuf( dev, ev_buf, _IOFBF, sizeof(ev_buf) );

    return OK;
}


int close_dev() {
    fclose(dev);
    return OK;
}


int grab_dev() {
    int ret;

    if (grabbed)
	return 0;

    ret = ioctl(fileno(dev), EVIOCGRAB, (void *)1);
    if (ret == 0)
	grabbed = 1;
    else
	printf("Error: could not grab %s: %s\n", device, strerror(errno));
    
    return ret;
}


int ungrab_dev() {
    int ret;

    if (!grabbed)
	return 0;

    ret = ioctl(fileno(dev), EVIOCGRAB, (void *)0);
    if (ret == 0)
	grabbed = 0;
    else
	printf("Error: could not ungrab %s: %s\n", device, strerror(errno));
	
    return ret;
}


int get_key(int *key, int *type, int tipo_read) {
    struct input_event ev;
    int ret;

    do {
        ret = fread(&ev, sizeof(ev), 1, dev);
        if (ret < 1) {
            printf("Error: failed to read event from %s: %s", device, strerror(errno));
            return READERR;
        }
    } while (ev.type != EV_KEY);

    *key = ev.code;

    switch (ev.value) {
	case 0:
	    *type = REL;
	    break;
	case 1:
	    *type = KEY;
	    break;
	case 2:
	    *type = REP;
	    break;
	default:
	    *type = INVALID;
    }

    if (*key > KEY_MAX)
	*type = INVALID;

    if (*type == INVALID) {
        printf("Error: invalid event read from %s: code = %u, value = %u", device, ev.code, ev.value);
	return EVERR;
    }

    return OK;
}


int snd_key(int key, int type) {
    struct input_event ev;
    int ret;

    // Preenche com o tempo atual
    gettimeofday( &ev.time, NULL );

    ev.type = EV_KEY;
    ev.code = key;

    switch (type) {
	case KEY:
	    ev.value = 1;
	    break;
	case REL:
	    ev.value = 0;
	    break;
	case REP:
	    ev.value = 2;
	    break;
	default:
	    return EINVAL;
    }

    ret = fwrite( &ev, sizeof(ev), 1, dev );
    if (ret < 1) {
	    printf("Error: failed to send event to %s: %s", device, strerror(errno));
	    return WRITEERR;
    }

    // ret = write(fd, &event, sizeof(event));
    // if(ret < sizeof(event)) {


    fflush( dev );
    usleep( 10000 );


    return OK;
}


int set_led(int led, int on) {
    struct input_event ev;
    int ret;

    ev.type = EV_LED;
    ev.code = led;
    ev.value = (on > 0);

    ret = fwrite(&ev, sizeof(ev), 1, dev);
    if (ret < 1) {
	printf("Error: failed to set LED at %s: %s", device, strerror(errno));
	return WRITEERR;
    }

    return OK;
}

*/

