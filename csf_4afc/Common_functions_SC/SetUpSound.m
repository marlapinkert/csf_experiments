InitializePsychSound(1);
% Number of channels and Frequency of the sound
nrchannels = 2;
freqAudio = single([500 1000]);

% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo output
% Set the volume - Ask participant
AudioDevice = PsychPortAudio('GetDevices');

if Parameters.Projector == 1
    if contains({AudioDevice.DeviceName},'D10')
        disp('D10 sensorimetric device connected.')
        idxAudio = find(contains({AudioDevice.DeviceName},'D10') == 1);
        AudioDeviceNb = AudioDevice(idxAudio).DeviceIndex;
        pahandle = PsychPortAudio('Open', AudioDeviceNb, 1, 1, [], nrchannels);
    else
        disp('Please connect D10 sensorimetric devices!')
        pahandle = PsychPortAudio('Open', [], 1, 1, [], nrchannels);
%         return
    end
else
    pahandle = PsychPortAudio('Open', [], 1, 1, [], nrchannels);
end
VolumeAudio = single(0.5);

%fixation break sound
EyeBeep = MakeBeep(300,0.05); %simple beep to repeat
EyeBeep = single(repmat([EyeBeep],[2 1])); %needs to be in stereo

%Response feedback sound
[yCorr,FsCorr] = audioread('CorrectAnswer.wav');
[yWrong,FsWrong] = audioread('WrongAnswer.wav');
[yCatch,FsCatch] = audioread('coin.wav');

clear nrchannels