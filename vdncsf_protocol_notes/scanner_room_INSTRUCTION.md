# vdncsf_protocol

## PREPARATION SECTION (TODO BEFORE PARTICIPANT ARRIVES)
* Have SD card ready for nCSF
* Put eye tracker in scanner; turn on battery; turn on eyelink PC

### Log in and screen setup 
[1] select alma linux (top option)
[2] log in with Classic X11 
[3] run scanner_room_startup.sh (setups screens all mirrored)

### Matlab setup (CSF10bit)
- Open matlab 
- run scanner_room_startup.m 
- Confirm all the paths; keep pressing enter 
- when it comes to the bits config stuff
press b when asked to input a letter
Then press s,  Esc, y, Enter to save and confirm the screen settings 
- do a test with loc

### Python setup (PRF)
- Open terminal in PRF_stimulus
cd Experiment
conda activate eyelink
- run a test 

[1] activate correct environemnt
conda activate eyelink

[2] Correct command to get it running 
python main.py --sub 999 --ses 1 --run 1 --eye 1 --task 2R_scanner

[3] Eyetracker 
* Check the correct eye is selected
* press (c) to Calibrate
* press (v) to validate
* press enter on eyelink keyboard to show eyelink camera
* press "esc" to got " WAITING FOR SCANNER screen
-> in scanner: wait for the scanner to start 





