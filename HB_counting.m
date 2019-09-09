%%% Heartbeat counting task
% Written by Dennis Larsson, September 2019, 
% Sackler Centre for Consciousness Sciences, University of Sussex, UK

% Script for heartbeat counting task. 
% Participant is wearing a pulse oximeter, and is for each trial to focus
% on their heart and try to count their heartbeats, and at the end of each
% trial report back the number of heartbeats counted, and confidence in the
% report. 

% Each trial will start and end with a tone. The participant is to count
% their heartbeats within the period of the two tones

% The participant is not to look at this screen


clear all 
clc

dir_script = cd; % File directory
dir_data = strcat(dir_script,'\data'); % Data directory for saving results files
if exist(dir_data) ~= 7 % If data folder does not exist...
    mkdir('data'); % ...create data folder in directory
end


%% ~~~~~ Startup configurations ~~~~~ %%
intervals   = [25,30,35,40,45,50]; % Interval list with trial durations (in seconds)
intervals_shuffled = intervals(randperm(length(intervals))); % shuffle interval order
n_trials = length(intervals_shuffled); % Number of trials


%% ~~~~~ Pulse_ox configurations ~~~~~ %%
port = 'COM5'; % Specify pulse_ox port
pulse_ox=serial(port,'BaudRate',9600,'DataBits',8); % open pulse_ox serial
fopen(pulse_ox); % Open pulse_ox port
buff=zeros(1,5,'uint8'); % Reset data buffer
sync_ok=0; % Reset for sync test


%% ~~~~~ Demographic data ~~~~~ %%
pxID = input('Define participant ID: ');
age = input('Define participant age: ');
sex = input('Define participant sex [M = 1 / W = 2]: ');
if isempty(pxID) || isempty(age) || isempty(sex) || ismember(sex,[1,2])==0 % check whether input is valid
    error('Invalid input')
end
px_str = strcat('px_',num2str(pxID)); % save pxID as string


%% ~~~~~ Prepare a data matrix ~~~~~ %%
% data(:,1) - id
% data(:,2) - age
% data(:,3) - sex
% data(:,4) - trial number
% data(:,5) - trial duration
% data(:,6) - recorded number of heartbeats
% data(:,7) - reported number of heartbeats
% data(:,8) - confidence rating: 0(guess) - 100(fully confident)
% data(:,9) - calculated accuracy
% data(:,10) - signal problem during trial (0=no; 1=yes)

data = nan(n_trials,10); % fill data matrix with nan for each datapoint of each trial


%% ~~~~~ Sound setup ~~~~~ %%
InitializePsychSound(1); % Initialize Sounddriver

config_sound.Nchan          = 1; % Number of channels 
config_sound.samplingRate   = 48000; % Frequency of the sound
config_sound.alert          = 600; % Tone Hz
config_sound.beepLengthSecs = 0.1; % Length of sound
config_sound.device         = 2; % Specify device number
config_sound.volume         = 1;% Volume for start/stop tone


%% ~~~~~ Main task loop ~~~~~ %%
for t = 1:n_trials % TRIAL LOOP START
    % Display start warning
    fprintf('\n\nLoading trial nr %d. \nReady to start trial? (press any key to continue)\n',t)
    pause;
    fprintf('\nTrial %d starting. Get ready...\n\n',t)
    pause(2)
    
    dur_trial = intervals_shuffled(t); % Pick trial duration from shuffled list

    % RUN TASK
    [data_beats, heartrate, data_trial] = task_main(pulse_ox,dur_trial,config_sound); % Main task function
    
    hb_real         = data_trial(1); % number of recorded heartbeats
    sensor_problem  = data_trial(2); % sensor problem during trial (yes=1; no=0)

    % ACCURACY QUESTION
    acc_resp = input('How many heartbeats did you count? '); % accuracy response

    % PAS QUESTION
    conf = input('How confident are you in your response (on a scale from 0 to 100)? ');

    % CALCULATE TRIAL ACCURACY
    acc   = 1-(abs(hb_real-acc_resp)/hb_real); % calculate accuracy based on heartbeats

    fprintf('Reported beats: %d \nActual beats: %d \nHit-rate: %.2f \n',acc_resp,hb_real,acc)

    % SAVE DATA
    data(t,:) = [pxID,age,sex,t,dur_trial,hb_real,acc_resp,conf,acc,sensor_problem];
end % TRIAL LOOP END

fprintf('Task finished. Exiting script...\n')
fclose(pulse_ox); % close the pulse_ox


%% Save data to file
cd(dir_data) % Change directory to data folder
xlswrite(px_str,data) % Write participant data file to directory


%% ~~~~~~~~~~~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~ %%


%% MAIN TASK FUNCTION
% Called for each trial
function [data_beats, heartrate, data_trial] = task_main(pulse_ox,dur_trial,config_sound)

% settings;

% % LOAD SOUND FUNCTION
Nchan           = config_sound.Nchan;
samplingRate    = config_sound.samplingRate;
freq_alert      = config_sound.alert;
beepLengthSecs  = config_sound.beepLengthSecs;
device          = config_sound.device;
vol_alert       = config_sound.volume;

pahandle = PsychPortAudio('Open', device, 1, 1, samplingRate, Nchan); % Open sound device

PsychPortAudio('Volume', pahandle, vol_alert); % Set the volume
tone_alert = MakeBeep(freq_alert, beepLengthSecs, samplingRate); % Alert tone, played at start and end of each trial
PsychPortAudio('FillBuffer', pahandle, tone_alert); % Fill buffer with the audio data, doubled for stereo presentation

% Reset data matrices
timing_beat = [];
timing_hour = [];
timing_minute = [];
timing_second = [];

% test connection
[buff, sync_ok] = sync_test(pulse_ox);
if sync_ok
    fprintf('Sync OK\n')
else
    return
end

previous_beat=0;
c = clock; % Start time of the heartbeats
tic; % Tic to start timing from
beats=0; % reset HB counter
tmp=toc;

while pulse_ox.BytesAvailable>5
    fread(pulse_ox,5,'uchar');
end

sensor_problem = 0; % logs if sensor problem during trial
task_running = true;
trial_start  = false;

% Retrieve the heartbeats
while task_running
    buff=cast(fread(pulse_ox,5,'uchar'),'uint8');
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0 %if all sync bits correct
        if sum(bitget(buff(2),4:7))>0
            fprintf('Sensor problem! (3)\n');
            if trial_start % if trial has started
                sensor_problem = 1; % log if sensor problem while trial is running
            end
        elseif sum(bitget(buff(2),2:3))>0  %if perfusion detected in status byte (see xpod manual page 10)
            if ~previous_beat
                previous_beat=1;
                if trial_start == false % wait for first beat to be registered before starting trial
                    fprintf('Trial start!\n')
                    trial_start = true; % Flag trial start
                    time_trial_start = toc; % Save time of trial start
                    PsychPortAudio('Start', pahandle, 1, 0, 1); % PLAY START TONE
                else
                    beats=beats+1; %increment beat counter
%                     fprintf('beat %d\n',beats) % Print to verify that beats are being registered
                    c = clock;
                    beat_count(beats) = beats;
                    timing_beat(beats) = toc; % Time taken since start of script
                    timing_hour(beats) = c(4); % Hour of the beat
                    timing_minute(beats) = c(5); % Minte of the beat
                    timing_second(beats) = c(6); % Second of the beat (to 3 dp)
                end
                
            end
        else
            previous_beat=0;
        end
    else
        fprintf('Loss of sync! (4)\n'); % Signal lost
        return;
    end
    if trial_start == true && toc > (time_trial_start + dur_trial) % If time is up, end trial
        PsychPortAudio('Start', pahandle, 1, 0, 1); % PLAY END TONE
        fprintf('Trial ended\n')
        data_trial = [beats,sensor_problem]; % SAVE DATA
        task_running = false; % End trial
    end      
end
% Save heartbeat data into matrix
data_beats = [beat_count', timing_beat', timing_hour', timing_minute', timing_second'];
heartrate = (timing_beat(beats) / beat_count(beats))*60;
end


%% ~~~~~ SYNC TEST FUNCTION ~~~~~ %%%
% Tests whether the pulse_ox is receiving a good signal. Called at the
% start of each trial through the main task function
function [buff, sync_ok] = sync_test(pulse_ox)
sync_ok = 0;
buff=zeros(1,5,'uint8');
tic;
% Read from pulseOx
while pulse_ox.BytesAvailable>10
    fread(pulse_ox,5,'uchar');
end

% Check synchronicity
while ~sync_ok
    buff=[buff(2:5),cast(fread(pulse_ox,1,'uchar'),'uint8')];
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
        sync_ok=1;
    elseif toc>5
        fprintf('Cannot sync with pulseoximeter (1)!\n');
        fclose(pulse_ox);
        % Surely should also have sync_ok = 1 here?
        return;
    end
end

% Check synchronicity again
buff=cast(fread(pulse_ox,5,'uchar'),'uint8');
sync_ok=0;
tic;
while ~sync_ok
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
        sync_ok=1;
    elseif toc>5
        fprintf('Cannot sync with pulseoximeter (2)!\n');
        fclose(pulse_ox);
        return;
    else
        buff=[buff(2:5),cast(fread(pulse_ox,1,'uchar'),'uint8')];
    end
end

end

