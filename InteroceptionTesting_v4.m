function varargout = InteroceptionTesting_v4(varargin)
% dbstop if error
% INTEROCEPTIONTESTING_V4 M-file for InteroceptionTesting_v4.fig
%      INTEROCEPTIONTESTING_V4, by itself, creates a new INTEROCEPTIONTESTING_V4 or raises the existing
%      singleton*.
%
%      H = INTEROCEPTIONTESTING_V4 returns the handle to a new INTEROCEPTIONTESTING_V4 or the handle to
%      the existing singleton*.
%
%      INTEROCEPTIONTESTING_V4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTEROCEPTIONTESTING_V4.M with the given input arguments.
%
%      INTEROCEPTIONTESTING_V4('Property','Value',...) creates a new INTEROCEPTIONTESTING_V4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InteroceptionTesting_v4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InteroceptionTesting_v4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".

% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help InteroceptionTesting_v4

% Last Modified by GUIDE v2.5 29-Mar-2019 14:07:35
% Modified by CG 18/09/14 (v2.0). 
% - Added time out and fclose(s) to first sync check
% - Changed false positive/negative output on hbdet: 'Positive' now refers
% to 'in sync', negative = out of sync.
% - set total number of trials to 6 for HBtracking, 20 for HB detection
% - Restyled box layout etc.

% Modified by CG June 2015 (v2.1). 
% - Default thresh changed from 0.35 to 0.25

% Modified by CG 10/08/15 (v2.2). 
% - Fixed file save path so results saved in location navigated to via 
% browse (previously only filname from browse was entered
% into edit12 text box). Now call uiputfile first on call to browse, then
% put both filename and path in edit12. edit12 contents then used for fid
% throughout.
% - changed in/out sync values to reset to 0 at start of next trial. This
% makes sure you have to click a radio for each trial. Contains errordlg
% to notify when a radio option has not been selected.
% - Updated "mental tracking" to "heartbeat tracking", and "heartbeat detection" to "discrimination", to reflect current
% wording. 
% - Also changed all refs of 'block', (e.g. "Next Block") to "trial".
% - Attempted to updated wavplay etc to sound, but does not play fast
% enough (?slow processing). Reverted to wavplay. TBA for next version.
% - Added try-catch to handle incorrect COM port number entered.
% - Added version number and BSMS info to results file. 
% - Updated test names in results file.

%Modified by LQ 31/01/18 (v.2.4_w_Time)
% - Added time tracking task
% - Set COMport default to COM3 for Sullivan - will vary on every computer!
% - Reduced size of GUI for Sullivan

%Modified by LQ 28/09/2018 (v3.0)
% - Changed to 26 trials for discrimination
% - Discrimination no longer shows whether it was in/out of sync - only for
% training, see InteroceptionTraining_v4
% shortened beep message to allow for faster heartbeats
% - Verified meaning of output files for discrimination:
% True positive - was in sync, identified as in sync
% True negative - was out of sync, identified as out of sync
% False positive - was out of sync, identified as in sync
% False negative - was in sync, identified as out of sync

%Modified by JM 04/03/19 (v4.0)
% - Changed sound output method to PsychPortAudio from Psychtoolbox
% - From now, this script requires Psychtoolbox
% This should allow for minimal audio latency, useful for machines with bad
% sound drivers.

% Begin initialization code - DO NOT EDIT
global fid;
global beep_message;
global start_message;
global stop_message;
load audio_messages
% beep_message=beep_message(1:5964);
beep_message=beep_message(1:3964); %shortened LQ 28/09/18

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InteroceptionTesting_v4_OpeningFcn, ...
                   'gui_OutputFcn',  @InteroceptionTesting_v4_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before InteroceptionTesting_V4pt0 is made visible.
function InteroceptionTesting_v4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InteroceptionTesting_v4 (see VARARGIN)

% Choose default command line output for InteroceptionTesting_v4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set_priority(-1, 6, 7);
rand('twister',sum(100*clock));
fclose all;
% UIWAIT makes InteroceptionTesting_v4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = InteroceptionTesting_v4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
warndlg('It is essential that you close ALL other applications before continuing!','Warning!', 'modal')
varargout{1} = handles.output;


% Mental tracking task routine (single trial)
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% load audio_messages;
% beep_message=beep_message(1:5964);
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton5,'Enable','off');
set(handles.pushbutton6,'Enable','off');
set(handles.edit1,'Enable','off');
set(handles.edit1,'String','');
set(handles.edit7,'Enable','inactive');
set(handles.edit7,'String','--');
set(handles.edit9,'Enable','inactive');
set(handles.edit9,'String','--');
set(handles.edit8,'Enable','off');
set(handles.edit8,'String','');
task_duration=str2double(get(handles.edit5,'String'));
if isnan(task_duration)||task_duration<=0||task_duration>240
    errordlg('Check your inputs...','Bad Input','modal'); 
    set(handles.pushbutton6,'String','Start');
    set(handles.pushbutton2,'Enable','on');
    set(handles.pushbutton5,'Enable','on');
    set(handles.pushbutton6,'Enable','on');
    return; 
end
fclose all;
s=serial(get(handles.edit10,'String'),'BaudRate',9600,'DataBits',8); %open puslse ox serial 
fopen(s);
set(handles.pushbutton6,'String','Sync''ing...');
buff=zeros(1,5,'uint8');
sync_ok=0;
tic;
while s.BytesAvailable>10 fread(s,5,'uchar'); end;
while ~sync_ok
    buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];      
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
        sync_ok=1;
    elseif toc>5
        errordlg('Cannot sync with pulseoximeter (1)!','Cannot sync','modal');
        fclose(s);        
        set(handles.pushbutton6,'String','Start');
        set(handles.pushbutton2,'Enable','on');
        set(handles.pushbutton5,'Enable','on');
        set(handles.pushbutton6,'Enable','on');
        return;
    end
end
buff=cast(fread(s,5,'uchar'),'uint8');
sync_ok=0;
tic;
while ~sync_ok
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
        sync_ok=1;
    elseif toc>5
        errordlg('Cannot sync with pulseoximeter (2)!','Cannot sync','modal');
        fclose(s);        
        set(handles.pushbutton6,'String','Start');
        set(handles.pushbutton2,'Enable','on');
        set(handles.pushbutton5,'Enable','on');
        set(handles.pushbutton6,'Enable','on');
        return;
    else         
        buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
    end
end
set(handles.pushbutton6,'String','Running...');
h=waitbar(0,'Running');
previous_beat=0;
tic;
beats=0;
tmp=toc;
global start_message;
% wavplay(start_message,48000,'async'); 

InitializePsychSound(1);
% Open the audio player with freq and nrchannels (2 for stereo)
nrchannels = 2;
freq = 48000;
repetitions = 1;
pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
% make the tone, add to the player
wavedata = [start_message' ; start_message'];
PsychPortAudio('FillBuffer', pahandle, wavedata)
% PsychPortAudio('Start', pahandle, 1, 0, 1);
PsychPortAudio('Stop', pahandle, 1, 0, 1);

%sound(start_message,48000); %**
while s.BytesAvailable>5 fread(s,5,'uchar'); end;
while toc<task_duration
    buff=cast(fread(s,5,'uchar'),'uint8');
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0 %if all sync bits correct
        if toc-tmp>1
            waitbar(toc/task_duration,h); %increment progress bar
            tmp=toc;
        end        
        if sum(bitget(buff(2),4:7))>0
            errordlg(sprintf('Sensor problem! (%.1f)',toc),'Sensor problem','modal');
            fclose(s);        
            set(handles.pushbutton6,'String','Start');
            set(handles.pushbutton2,'Enable','on');
            set(handles.pushbutton5,'Enable','on');
            set(handles.pushbutton6,'Enable','on');
            close(h);
            return;
        elseif sum(bitget(buff(2),2:3))>0  %if perfusion detected in status byte (see xpod manual page 10)
            if ~previous_beat
                previous_beat=1;
                beats=beats+1; %increment beat counter
            end
        else
            previous_beat=0;
        end                
    else
        errordlg(sprintf('Loss of sync! (%.1f)',toc),'Loss of sync','modal');
        fclose(s);        
        set(handles.pushbutton6,'String','Start');
        set(handles.pushbutton2,'Enable','on');
        set(handles.pushbutton5,'Enable','on');
        set(handles.pushbutton6,'Enable','on');
        close(h);
        return;        
    end
end
global stop_message;
% wavplay(stop_message,48000,'async'); 

InitializePsychSound(1);
% Open the audio player with freq and nrchannels (2 for stereo)
nrchannels = 2;
freq = 48000;
repetitions = 1;
pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
% make the tone, add to the player
wavedata = [stop_message' ; stop_message'];
PsychPortAudio('FillBuffer', pahandle, wavedata)
% PsychPortAudio('Start', pahandle, 1, 0, 1);
PsychPortAudio('Stop', pahandle, 1, 0, 1);

set(handles.edit9,'String',sprintf('%.0f',60*beats/task_duration)); %show beats/min
set(handles.edit7,'String',sprintf('%d',beats)); %show beats counted
fclose(s);
close(h);
set(handles.pushbutton6,'String','Start');
set(handles.pushbutton2,'Enable','on');
set(handles.pushbutton5,'Enable','on');
set(handles.pushbutton6,'Enable','on');

PsychPortAudio('Close', pahandle);


% Heartbeat detection task routine (single trial)
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load audio_messages
% beep_message=beep_message(1:5964);
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton5,'Enable','off');
set(handles.pushbutton6,'Enable','off');
set(handles.edit1,'Enable','off');
set(handles.edit1,'String','');
set(handles.edit7,'Enable','off');
set(handles.edit7,'String','');
set(handles.edit8,'Enable','inactive');
set(handles.edit8,'String','--');
set(handles.edit9,'Enable','off');
set(handles.edit9,'String','');
task_duration=str2double(get(handles.edit2,'String'));
pulse_delay=str2double(get(handles.edit4,'String')); %delay for in sync (0s) and out of sync trials (variable duration. default set to 0.3s)
if isnan(task_duration)||isnan(pulse_delay)||task_duration<=0||task_duration>240||pulse_delay<0||pulse_delay>1
    errordlg('Check your inputs...','Bad Input','modal'); 
    set(handles.pushbutton5,'String','Start');
    set(handles.pushbutton2,'Enable','on');
    set(handles.pushbutton5,'Enable','on');
    set(handles.pushbutton6,'Enable','on');
    return; 
end
fclose all;

% Psychtoolbox Port Audio Setup % JM 04/02/19
% Initialize Sounddriver
InitializePsychSound(1);
% Open the audio player with freq and nrchannels (2 for stereo)
nrchannels = 2;
freq = 48000;
repetitions = 1;
pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
% make the tone, add to the player
tone = [zeros(cast(floor(pulse_delay*48000),'int16'),1); beep_message]';
wavedata = [tone; tone];
PsychPortAudio('FillBuffer', pahandle, wavedata)
% PsychPortAudio('Start', pahandle, 1, 0, 1);
PsychPortAudio('Stop', pahandle, 1, 0, 1);

s=serial(get(handles.edit10,'String'),'BaudRate',9600,'DataBits',8); %open pulse ox serial 
fopen(s);
set(handles.pushbutton5,'String','Sync''ing...');
buff=zeros(1,5,'uint8');
sync_ok=0;
tic;
while s.BytesAvailable>10 fread(s,5,'uchar'); end;
while ~sync_ok %attempt sync
    buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];      
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
        sync_ok=1;
    elseif toc>5 %attempt sync for 5 seconds
        errordlg('Cannot sync with pulseoximeter (1)!','Cannot sync','modal');
        fclose(s);        
        set(handles.pushbutton5,'String','Start');
        set(handles.pushbutton2,'Enable','on');
        set(handles.pushbutton5,'Enable','on');
        set(handles.pushbutton6,'Enable','on');
        return;
    end
end
buff=cast(fread(s,5,'uchar'),'uint8');
sync_ok=0;
tic;
while ~sync_ok
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
        sync_ok=1;
    elseif toc>5
        errordlg('Cannot sync with pulseoximeter (2)!','Cannot sync','modal');
        fclose(s);        
        set(handles.pushbutton6,'String','Start');
        set(handles.pushbutton2,'Enable','on');
        set(handles.pushbutton5,'Enable','on');
        set(handles.pushbutton6,'Enable','on');
        return;
    else         
        buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
    end
end
set(handles.pushbutton5,'String','Calibrating...'); %begin calibration (determine rise/inflection point in pleth)
h=waitbar(0,'Running');
previous_pleth=1000;
% pause on;
beats=0;
tmpbuff_max=[];
% tmpbuff_min=[];
for i=1:20 %calculate the maximum differential over 20 seconds of sampling
    buff=cast(fread(s,5*75,'uchar'),'uint8');
    buff=reshape(buff,[5 75]); %75 Hz sampling, .: capture 1 second
    pleth=cast(squeeze(buff(3,:)),'double'); %Byte 3 - pleth byte (xpod manual page 11)
    tmpbuff_max=[tmpbuff_max,max(diff(pleth))]; %maximum differential in samples (append to previous)
%    tmpbuff_min=[tmpbuff_min,min(diff(pleth))];
end
threshold_max=mean(tmpbuff_max)*str2double(get(handles.edit11,'String')); %calculate threshold for riase as a fraction of maximum differential (from thresh set in gui)
% threshold_min=mean(tmpbuff_min)*0.5;
% wavplay(start_message,48000,'async');
set(handles.pushbutton5,'String','Running...');
while s.BytesAvailable>5 fread(s,5,'uchar'); end;
tic;
tmp=toc;
tmp2=toc;
cnt=1;
log_pleth=zeros(1,30*75);
log_armed=zeros(1,30*75);
log_der=zeros(1,30*75);
log_beats=zeros(1,30*75);
armed=0;
previous_beatval=1;
while toc<task_duration 
    while s.BytesAvailable>10 fread(s,5,'uchar'); end;
    buff=cast(fread(s,5,'uchar'),'uint8');
    pleth=cast(buff(3),'double');
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
        der=pleth-previous_pleth;     %continuous differential calculation   
        if toc-tmp>1
            waitbar(toc/task_duration,h);
            tmp=toc;
        end
        if sum(bitget(buff(2),4:7))>0
            errordlg(sprintf('Sensor problem! (%.1f)',toc),'Sensor problem','modal');
            fclose(s);        
            set(handles.pushbutton5,'String','Start');
            set(handles.pushbutton2,'Enable','on');
            set(handles.pushbutton5,'Enable','on');
            set(handles.pushbutton6,'Enable','on');
            close(h);
            return;
        elseif armed&&der>=threshold_max %if continuous defferental excedes calculated threshold
            if pleth/previous_beatval>1.5 %if the pleth value is >1.58previous value, assume we have missed the rise
            else %play tone with delay
                
                % Start audio % JM 04/03/19
                PsychPortAudio('Start', pahandle, 1, 0, 1);
                
                beats=beats+1;
                log_beats(cnt)=1;
            end
            previous_beatval=pleth;
            armed=0;
            tmp2=toc;
        elseif toc-tmp2>0.35
            armed=1;
        end
        previous_pleth=pleth;        
        log_pleth(cnt)=pleth;
        log_armed(cnt)=armed;
        log_der(cnt)=der;
%        log_previousder(cnt)=previous_der;        
        cnt=cnt+1;        
    else
        errordlg(sprintf('Loss of sync! (%.1f)',toc),'Loss of sync','modal');
        fclose(s);        
        set(handles.pushbutton5,'String','Start');
        set(handles.pushbutton2,'Enable','on');
        set(handles.pushbutton5,'Enable','on');
        set(handles.pushbutton6,'Enable','on');
        close(h);
        return;        
    end
    % Stop playback: %JM 04/03/19
    PsychPortAudio('Stop', pahandle, 1);
end
% wavplay(stop_message,48000,'async');


% Close the audio device: % JM 04/03/19
PsychPortAudio('Close', pahandle);
% pause off;
set(handles.edit8,'String',sprintf('%.0f',60*beats/task_duration));
close(h);
fclose(s);
set(handles.pushbutton5,'String','Start');
set(handles.pushbutton2,'Enable','on');
set(handles.pushbutton5,'Enable','on');
set(handles.pushbutton6,'Enable','on');


% Pulse oximeter test routine
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton2,'String','Wait...');
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton5,'Enable','off');
set(handles.pushbutton6,'Enable','off');
set(handles.edit7,'Enable','off');
set(handles.edit7,'String','');
set(handles.edit9,'Enable','off');
set(handles.edit9,'String','');
set(handles.edit1,'Enable','inactive');
set(handles.edit1,'String','');
set(handles.edit8,'Enable','off');
set(handles.edit8,'String','');
fclose all;
s=serial(get(handles.edit10,'String'),'BaudRate',9600,'DataBits',8); %get(handles.edit10) string = COM port number

try fopen(s);
catch ME
    str = 'Use INSTRFIND to determine if other instrument objects are connected to the requested device.';
    errstr = regexprep(ME.message,str,'');
    errordlg(errstr,'Cannont connect to COM','modal');
    set(handles.pushbutton2,'String','Test');
    set(handles.pushbutton2,'Enable','on');
    set(handles.pushbutton5,'Enable','on');
    set(handles.pushbutton6,'Enable','on');
    return
end


set(handles.edit1,'String','Waiting sync...');
buff=zeros(1,5,'uint8');
sync_ok=0;
duration=5;
tic
while ~sync_ok && toc<duration
    buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];      
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
        sync_ok=1;
    end
end
if ~sync_ok
    set(handles.edit1,'String','Check USB and COM#.');
    fclose(s);
    set(handles.pushbutton2,'String','Test');
    set(handles.pushbutton2,'Enable','on');
    set(handles.pushbutton5,'Enable','on');
    set(handles.pushbutton6,'Enable','on');
    return;   
end
%duration=5;
set(handles.edit1,'String','Measuring...');
tic;
unusable_frames=0;
total_frames=0;
beats=0;
sync_errors=0;
previous_beat=0;
weak_beats=0;
while toc<duration 
    buff=cast(fread(s,5,'uchar'),'uint8');
    if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
        total_frames=total_frames+1;
        if sum(bitget(buff(2),4:7))>0
            unusable_frames=unusable_frames+1;
            previous_beat=0;
        elseif sum(bitget(buff(2),2:3))>0
            if ~previous_beat
                if bitget(buff(2),2)==0
                    weak_beats=weak_beats+1;
                end
                beats=beats+1;                
                previous_beat=1;
            end
        else
            previous_beat=0;
        end                
    else
        sync_ok=0;
        while ~sync_ok
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
                sync_ok=1;
            end
        end
        sync_errors=sync_errors+1;
    end       
end
if sync_errors>0
    set(handles.edit1,'String','Comms problem!');
elseif unusable_frames/total_frames>0.001
    set(handles.edit1,'String','Sensor problem (unusable frames)!');
elseif beats>240/60*duration||beats<30/60*duration     
    set(handles.edit1,'String','Readout problem (hr out of range)!');
elseif weak_beats/beats>0.01
    set(handles.edit1,'String','Reposition sensor (weak beats)!');    
else
    set(handles.edit1,'String','All OK!');
end 
fclose(s);
set(handles.pushbutton2,'String','Test');
set(handles.pushbutton2,'Enable','on');
set(handles.pushbutton5,'Enable','on');
set(handles.pushbutton6,'Enable','on');

% --- Executes on button press in pushbutton7 (browse to results file
% location)
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 [filename,pathname] = uiputfile('*.txt','Set the location to save results');
 set(handles.edit12,'String',fullfile(pathname,filename));                            
%set(handles.edit12,'String',uiputfile('*.txt'));                                %**this is the file path for the results file to be saved. Edit this to save to the correct directory
    set(handles.pushbutton8,'Enable','on');

% --- Executes on button press in pushbutton8. (open results file)
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global fid;
    if strcmp(get(handles.pushbutton8,'String'),'Open')
        fid=fopen(get(handles.edit12,'String'),'w+');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton8,'String','Close');
        set(handles.edit12,'Enable','off');
        set(handles.pushbutton7,'Enable','off');
        set(handles.edit13,'Enable','off');
        set(handles.edit18,'Enable','off');
        fprintf(fid,'Interoception Testing, Version 3.0\r\n'); %**
        fprintf(fid,'Dept. of Psychiatry, Brighton and Sussex Medical School (H.Critchley@bsms.ac.uyk)\r\n'); %**
        fprintf(fid,'\r\n');
        fprintf(fid,'Subject ID: %s\r\n',get(handles.edit13,'String'));
        fprintf(fid,'Date/Time: %s\r\n',datestr(clock));
        fprintf(fid,'Comment: %s\r\n',get(handles.edit18,'String'));
        fprintf(fid,'-----------------------------------------------\r\n');       
        fprintf(fid,'\r\n');
        set(handles.pushbutton2,'Enable','off');
        set(handles.pushbutton5,'Enable','off');
        set(handles.pushbutton6,'Enable','off');
        set(handles.pushbutton16,'Enable','on');
        set(handles.edit2,'Enable','off');
        set(handles.edit4,'Enable','off');
        set(handles.edit5,'Enable','off');
        set(handles.edit10,'Enable','off');
        set(handles.edit11,'Enable','off');       
    elseif strcmp(get(handles.pushbutton8,'String'),'Close')
        fclose(fid);
        fid=-1;
        set(handles.pushbutton9,'Enable','off');
        set(handles.pushbutton11,'Enable','off');
        set(handles.pushbutton8,'String','Open');
        set(handles.pushbutton16,'Enable','off');
        set(handles.edit12,'Enable','on');
        set(handles.edit13,'Enable','on');
        set(handles.edit18,'Enable','on');
        set(handles.pushbutton7,'Enable','on');      
        set(handles.pushbutton8,'Enable','off');
        %winopen(get(handles.edit12,'String')); %** disabled call to open
        %results file immediately after testing finished
        set(handles.pushbutton2,'Enable','on');
        set(handles.pushbutton5,'Enable','on');
        set(handles.pushbutton6,'Enable','on');
        set(handles.edit2,'Enable','on');
        set(handles.edit4,'Enable','on');
        set(handles.edit5,'Enable','on');
        set(handles.edit10,'Enable','on');
        set(handles.edit11,'Enable','on');
    end

function f=hr_task_do_block(mode, thrs_coeff) %heart beat discrimination routine
    global s;
    if mode==0
        pulse_delay=0; %in sync (on beat)
    elseif mode==1
        pulse_delay=0.300; %out of sync (off beat)
    end
    total_beats=10; %present tone over 10 beats
    
 
    
    
    f=-1;
    while s.BytesAvailable>5 fread(s,5,'uchar'); end;
    buff=zeros(1,5,'uint8');
    sync_ok=0;
    tic;
    while ~sync_ok
        buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];      
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
            sync_ok=1;
        elseif toc>5
            errordlg('Cannot sync with pulseoximeter, press next to retry!','Cannot sync','modal');
%            fclose(s);
            return;
        end
    end
    buff=cast(fread(s,5,'uchar'),'uint8')';
    sync_ok=0;
    tic;
    while ~sync_ok
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
            sync_ok=1;
        elseif toc>5
            errordlg('Cannot sync with pulseoximeter, press next to retry!','Cannot sync','modal');
%            fclose(s);
            return;
        else         
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
        end
    end   
    buff=cast(fread(s,5,'uchar'),'uint8')';
    sync_ok=0;
    tic;
    while ~sync_ok
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
            sync_ok=1;
        elseif toc>5
            errordlg('Cannot sync with pulseoximeter, press next to retry!','Cannot sync','modal');
%            fclose(s);
            return;
        else         
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
        end
    end   
    h=waitbar(0,'Running');
    previous_pleth=1000;
%     global start_message;
%     wavplay(start_message,48000,'async');
    while s.BytesAvailable>5 fread(s,5,'uchar'); end;
    tic;
    armed=0;
    beats=0;
    previous_beatval=1;
    global hr_task_dermax;
    pleth_buff=zeros(1,75);    
    global hr_task_beatscnt;
    global hr_task_hracc;
    global hr_task_hrsqacc;
    global hr_task_blk_beatscnt;
    global hr_task_blk_hracc;
    global hr_task_blk_hrsqacc;
    hr_task_blk_beatscnt=0;
    hr_task_blk_hracc=0;
    hr_task_blk_hrsqacc=0;
    global beep_message;
    
       % Psychtoolbox Port Audio Setup % JM 04/02/19
    % Initialize Sounddriver
    InitializePsychSound(1);
    % Open the audio player with freq and nrchannels (2 for stereo)
    nrchannels = 2;
    freq = 48000;
    repetitions = 1;
    pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
    % make the tone, add to the player
    tone = [zeros(cast(floor(pulse_delay*48000),'int16'),1); beep_message]';
    wavedata = [tone; tone];
    PsychPortAudio('FillBuffer', pahandle, wavedata)
%     PsychPortAudio('Start', pahandle, 1, 0, 1);
    PsychPortAudio('Stop', pahandle, 1, 0, 1);
    
    
    while beats<total_beats
        threshold_max=mean(hr_task_dermax)*thrs_coeff; %threshold max from pushbutton9 calibration stage
        while s.BytesAvailable>10 fread(s,5,'uchar'); end;
        buff=cast(fread(s,5,'uchar'),'uint8');
        pleth=cast(buff(3),'double');
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
            der=pleth-previous_pleth;        
            pleth_buff=[pleth_buff(2:75),der];
            if sum(bitget(buff(2),4:7))>0
                errordlg(sprintf('Sensor problem, press next to retry!'),'Sensor problem','modal');
%                fclose(s);        
                close(h);
                return;
            elseif armed&&der>=threshold_max
                if pleth/previous_beatval>1.5
                else
                    % Start audio % JM 04/03/19
                    PsychPortAudio('Start', pahandle, 1, 0, 1);
                    %wavplay([zeros(cast(floor(pulse_delay*48000),'int16'),1);beep_message],48000,'async'); %**
                    %sound([zeros(cast(floor(pulse_delay*48000),'int16'),1);beep_message],48000); %** %**NOT FAST ENOUGH!
                    hr_task_dermax=[hr_task_dermax(2:20),max(pleth_buff)];
                    waitbar(beats/total_beats,h);
                    if beats>0
                        hr_task_beatscnt=hr_task_beatscnt+1;
                        hr_task_hracc=hr_task_hracc+(60/toc);
                        hr_task_hrsqacc=hr_task_hrsqacc+(60/toc)^2;
                        hr_task_blk_beatscnt=hr_task_blk_beatscnt+1;
                        hr_task_blk_hracc=hr_task_blk_hracc+(60/toc);
                        hr_task_blk_hrsqacc=hr_task_blk_hrsqacc+(60/toc)^2;
                    end
                    beats=beats+1;
                end
                previous_beatval=pleth;
                armed=0;
                tic;
            elseif toc>0.35
                armed=1;
            end
            previous_pleth=pleth;
        else
            errordlg(sprintf('Loss of sync, press next to retry!'),'Loss of sync','modal');
%            fclose(s);        
            close(h);
            return;        
        end 
        % Stop playback: %JM 04/03/19 % the 1 = wait until playback
        % finished before stopping. Sound is 90ms, but 390ms on async
        % trials.
        PsychPortAudio('Stop', pahandle, 1);
    end
    

    % Close the audio device: % JM 04/03/19
    PsychPortAudio('Close', pahandle);
%     global stop_message;
%     wavplay(stop_message,48000,'async');
    close(h);
    f=0;
    return;
        
    
% --- Executes on button press in pushbutton9 (heart beat discrimiation - full
% task)
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global hr_task_dermax;
    global hr_task_beatscnt;
    global hr_task_hracc;
    global hr_task_hrsqacc;
    global hr_task_tp;
    global hr_task_tn;
    global hr_task_fp;
    global hr_task_fn;
    global fid;
    global hr_task_blockno;
    global hr_task_vector;
    global s;
    global hr_task_last_written;
    if strcmp(get(handles.pushbutton9,'String'),'Begin')
        set(handles.pushbutton8,'Enable','off');
        set(handles.pushbutton9,'Enable','off');
        set(handles.pushbutton9,'String','Abort');
        set(handles.pushbutton11,'Enable','off');
        set(handles.pushbutton12,'Enable','off');
        set(handles.pushbutton10,'Enable','off');
        set(handles.edit17,'Enable','off');
        set(handles.edit17,'String','');
        set(handles.radiobutton1,'Enable','off');
        set(handles.radiobutton3,'Enable','off');
        while sum(hr_task_vector)~=16; hr_task_vector=round(rand(1,32)); end; % changed to 26 trials LQ 28/09/18 %create a random vector of n=20 0:1, and round. Continue to generate vectors until the sum of the vector is 10 (50% of trials are 1)
%        while sum(hr_task_vector)~=2 hr_task_vector=round(rand(1,4)); end;
%        for testing only
        hr_task_blockno=1;
        s=serial(get(handles.edit10,'String'),'BaudRate',9600,'DataBits',8);
        fopen(s);
        fprintf(fid,'\r\n'); %write to results file
        fprintf(fid,'-----------------------------------------------\r\n');       
        fprintf(fid,'            Heartbeat discrimination task\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');       
        fprintf(fid,'\r\n');
        h=waitbar(0,'Syncing and calibrating...');
        buff=zeros(1,5,'uint8');
        sync_ok=0;
        tic;
        while ~sync_ok
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];      
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
                sync_ok=1;
            elseif toc>5
                errordlg('Cannot sync with pulseoximeter, task aborted!','Cannot sync','modal');
                fprintf(fid,'Aborted!\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'-----------------------------------------------\r\n');                  
                close(h);
                fclose(s);        
                set(handles.pushbutton9,'Enable','on');
                set(handles.pushbutton9,'String','Begin');
                set(handles.pushbutton11,'Enable','on');            
                return;
            end
        end
        waitbar(0.10,h);
        buff=cast(fread(s,5,'uchar'),'uint8')';
        sync_ok=0;
        tic;
        while ~sync_ok
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
                sync_ok=1;
            elseif toc>5
                errordlg('Cannot sync with pulseoximeter, task aborted!','Cannot sync','modal');
                fprintf(fid,'Aborted!\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'-----------------------------------------------\r\n');                  
                close(h);
                fclose(s);        
                set(handles.pushbutton9,'Enable','on');
                set(handles.pushbutton9,'String','Begin');
                set(handles.pushbutton11,'Enable','on');            
                return;
            else         
                buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
            end
        end
        waitbar(0.15,h);
        buff=cast(fread(s,5,'uchar'),'uint8')';
        sync_ok=0;
        tic;
        while ~sync_ok
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
                sync_ok=1;
            elseif toc>5
                errordlg('Cannot sync with pulseoximeter, task aborted!','Cannot sync','modal');
                fprintf(fid,'Aborted!\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'-----------------------------------------------\r\n');                  
                close(h);
                fclose(s);        
                set(handles.pushbutton9,'Enable','on');
                set(handles.pushbutton9,'String','Begin');
                set(handles.pushbutton11,'Enable','on');            
                return;
            else         
                buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
            end
        end
        waitbar(0.3,h);   
        hr_task_dermax=[];
        for i=1:20
            if i==10
                waitbar(0.6,h);
            end
            buff=cast(fread(s,5*75,'uchar'),'uint8');
            buff=reshape(buff,[5 75]);
            pleth=cast(squeeze(buff(3,:)),'double');
            hr_task_dermax=[hr_task_dermax,max(diff(pleth))]; %**inflection point for 1 beat (75 pleth samples)
        end
        set(handles.pushbutton9,'Enable','off');      
        close(h);
        hr_task_beatscnt=0;
        hr_task_hracc=0;
        hr_task_hrsqacc=0;
        hr_task_tp=0;
        hr_task_tn=0;
        hr_task_fp=0;
        hr_task_fn=0;    
        if hr_task_do_block(hr_task_vector(hr_task_blockno), str2double(get(handles.edit11,'String')))==0 %** first block of hbdesc
            set(handles.pushbutton10,'Enable','on');
            set(handles.radiobutton1,'Value',0); %** rest both radio buttons to blank between trials
            set(handles.radiobutton3,'Value',0); %**           
            set(handles.radiobutton1,'Enable','on');
            set(handles.radiobutton3,'Enable','on');
            set(handles.edit17,'Enable','inactive');
            set(handles.edit17,'String',sprintf('%d',hr_task_blockno));
%             if hr_task_vector(hr_task_blockno)
%                 set(handles.edit17,'String',[int2str(hr_task_blockno) ': out of sync']);
%             else
%                 set(handles.edit17,'String',[int2str(hr_task_blockno) ': in sync']);
%             end
            hr_task_blockno=hr_task_blockno+1;
            hr_task_last_written=0;
            set(handles.pushbutton9,'Enable','on');
            return;
        else
            fprintf(fid,'Problem during first block, task aborted!\r\n');
            fprintf(fid,'\r\n');
            fprintf(fid,'-----------------------------------------------\r\n');
            fclose(s);
            set(handles.pushbutton9,'Enable','on');
            set(handles.pushbutton11,'Enable','on');
            set(handles.pushbutton9,'String','Begin');
            return;
        end
    else
        fprintf(fid,'Task aborted by user!\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');
        fclose(s);
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton10,'Enable','off');
        set(handles.radiobutton1,'Enable','off');
        set(handles.radiobutton3,'Enable','off');
        set(handles.edit17,'Enable','off');
        set(handles.edit17,'String','');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton9,'String','Begin');
        set(handles.pushbutton8,'Enable','on');
        return;
    end
    

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.radiobutton1,'Value',1);
    set(handles.radiobutton3,'Value',0);


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.radiobutton1,'Value',0);
    set(handles.radiobutton3,'Value',1);


% --- Executes on button press in pushbutton10 (hb discrimination next
% trial)
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global hr_task_vector;
    global hr_task_blockno;
    global s;
    global hr_task_tp;
    global hr_task_tn;
    global hr_task_fp;
    global hr_task_fn;
    global fid;
    global hr_task_beatscnt;
    global hr_task_hracc;
    global hr_task_hrsqacc;
    global hr_task_last_written;
    global hr_task_blk_beatscnt;
    global hr_task_blk_hracc;
    global hr_task_blk_hrsqacc;

    if ~get(handles.radiobutton1,'Value') && ~get(handles.radiobutton3,'Value') %**if neither radio button has been selected for the previous trial...
        errordlg('Please enter an in/out sync response to the previous trial.','Enter response','modal');
        return
    end

    
    set(handles.pushbutton9,'Enable','off');
    set(handles.pushbutton10,'Enable','off');
    set(handles.radiobutton1,'Enable','off');
    set(handles.radiobutton3,'Enable','off');

    %** note in previous version a "positve" was a trial with a delay.
    %This was counter-intuitive for many researchers (positive was considered to be in sync/on-beat), .: posative and
    %negative have been switched in the printed output.
        
    if hr_task_blockno==length(hr_task_vector)+1
        if hr_task_vector(hr_task_blockno-1)
            if get(handles.radiobutton3,'Value')
                hr_task_tp=hr_task_tp+1;
                fprintf(fid,'Block %d: True negative (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                %fprintf(fid,'Block %d: True positive (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
            else
                hr_task_fn=hr_task_fn+1;
                fprintf(fid,'Block %d: False positive (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                %fprintf(fid,'Block %d: False negative (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
            end
        else
            if get(handles.radiobutton1,'Value')
                hr_task_tn=hr_task_tn+1;
                fprintf(fid,'Block %d: True positive (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                %fprintf(fid,'Block %d: True negative (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
            else
                hr_task_fp=hr_task_fp+1;
                fprintf(fid,'Block %d: False negative (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                %fprintf(fid,'Block %d: False postive (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
            end            
        end
        fprintf(fid,'\r\n');
        fprintf(fid,'Total true negatives %d\r\n',hr_task_tp); %**only switched the text writen in the outputfile (negative->positive), and not the counter
        %fprintf(fid,'Total true positives %d\r\n',hr_task_tp);
        fprintf(fid,'Total true positives %d\r\n',hr_task_tn);
        %fprintf(fid,'Total true negatives %d\r\n',hr_task_tn);
        fprintf(fid,'Total false negatives %d\r\n',hr_task_fp);
        %fprintf(fid,'Total false positives %d\r\n',hr_task_fp);
        fprintf(fid,'Total false positives %d\r\n',hr_task_fn);
        %fprintf(fid,'Total false negatives %d\r\n',hr_task_fn);
        fprintf(fid,'Overall accuracy %d%%\r\n',round(100*(hr_task_tp+hr_task_tn)/(hr_task_tp+hr_task_tn+hr_task_fp+hr_task_fn))); %accuracy calculation
        fprintf(fid,'\r\n');
        fprintf(fid,'Average heart rate (bpm) %.1f\r\n',hr_task_hracc/hr_task_beatscnt);
        fprintf(fid,'SD heart rate (bpm) %.1f\r\n',sqrt((hr_task_hrsqacc-hr_task_beatscnt*(hr_task_hracc/hr_task_beatscnt)^2)/hr_task_beatscnt));
        fprintf(fid,'\r\n');       
        fprintf(fid,'-----------------------------------------------\r\n');
        fclose(s);
        set(handles.pushbutton8,'Enable','on');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton10,'Enable','off');
        set(handles.radiobutton1,'Value',0); %**
        set(handles.radiobutton3,'Value',0); %**
        set(handles.radiobutton1,'Enable','off');
        set(handles.radiobutton3,'Enable','off');
        set(handles.edit17,'Enable','off');
        set(handles.edit17,'String','');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton9,'String','Begin');
        set(handles.pushbutton10,'String','Next block');
        return;
    elseif hr_task_blockno>1
        if ~hr_task_last_written
            if hr_task_vector(hr_task_blockno-1) %if task vector is 1 (out of sync)
                if get(handles.radiobutton3,'Value') %if radio3 (out of sync) is selected
                    hr_task_tp=hr_task_tp+1; %increment true count, print true negative (out of sync) result for the previous trial, with mean bmp and standard deviation
                    fprintf(fid,'Block %d: True negative (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                    %fprintf(fid,'Block %d: True positive (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                else %if radio3 not selected
                    hr_task_fn=hr_task_fn+1; %increment false count, assume radio1 (in sync) is selected and .: print false postive result for the previous trial
                    fprintf(fid,'Block %d: False positive (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                    %fprintf(fid,'Block %d: False negative (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                end
            else %if task vector is 0 (in of sync)
                if get(handles.radiobutton1,'Value')
                    hr_task_tn=hr_task_tn+1;
                    fprintf(fid,'Block %d: True positive (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                    %fprintf(fid,'Block %d: True negative (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                else
                    hr_task_fp=hr_task_fp+1;
                    fprintf(fid,'Block %d: False negative (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                    %fprintf(fid,'Block %d: False postive (%.1f,%.1f)\r\n',hr_task_blockno-1,hr_task_blk_hracc/hr_task_blk_beatscnt,sqrt((hr_task_blk_hrsqacc-hr_task_blk_beatscnt*(hr_task_blk_hracc/hr_task_blk_beatscnt)^2)/hr_task_blk_beatscnt));
                end            
            end
            hr_task_last_written=1;
        end
        if hr_task_do_block(hr_task_vector(hr_task_blockno), str2double(get(handles.edit11,'String')))==0 %** 2nd to final blocks of hb desc
            set(handles.pushbutton9,'Enable','on');
            set(handles.pushbutton10,'Enable','on');
            set(handles.radiobutton1,'Value',0); %**
            set(handles.radiobutton3,'Value',0); %**
            set(handles.radiobutton1,'Enable','on');
            set(handles.radiobutton3,'Enable','on');
            set(handles.edit17,'Enable','inactive');
            set(handles.edit17,'String',sprintf('%d',hr_task_blockno));
%             if hr_task_vector(hr_task_blockno)
%                 set(handles.edit17,'String',[int2str(hr_task_blockno) ': out of sync']);
%             else
%                 set(handles.edit17,'String',[int2str(hr_task_blockno) ': in sync']);
%             end

            hr_task_blockno=hr_task_blockno+1;
            hr_task_last_written=0;
            if hr_task_blockno==length(hr_task_vector)+1
                set(handles.pushbutton10,'String','Finish');
            end
            return;
        else
            set(handles.pushbutton9,'Enable','on');
            set(handles.pushbutton10,'Enable','on');
            set(handles.radiobutton1,'Enable','on');
            set(handles.radiobutton3,'Enable','on');
        end
    else
        fprintf(fid,'Aborted!\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');
        fclose(s);
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton10,'Enable','off');
        set(handles.radiobutton1,'Enable','off');
        set(handles.radiobutton3,'Enable','off');
        set(handles.edit17,'Enable','off');
        set(handles.edit17,'String','');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton9,'String','Begin');
        set(handles.pushbutton8,'Enable','on');
        return;        
    end

function f=mt_task_do_block(block_duration) %mental tracking task routine
    global s;
    f=-1;
    global mt_beats;
    mt_beats=-1;
    while s.BytesAvailable>5 fread(s,5,'uchar'); end;
    buff=zeros(1,5,'uint8');
    sync_ok=0;
    tic;
    while ~sync_ok
        buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];      
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
            sync_ok=1;
        elseif toc>5
            errordlg('Cannot sync with pulseoximeter, press next to retry!','Cannot sync','modal');
%            fclose(s);
            return;
        end
    end
    buff=cast(fread(s,5,'uchar'),'uint8')';
    sync_ok=0;
    tic;
    while ~sync_ok
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
            sync_ok=1;
        elseif toc>5
            errordlg('Cannot sync with pulseoximeter, press next to retry!','Cannot sync','modal');
%            fclose(s);
            return;
        else         
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
        end
    end   
    buff=cast(fread(s,5,'uchar'),'uint8')';
    sync_ok=0;
    tic;
    while ~sync_ok
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
            sync_ok=1;
        elseif toc>5
            errordlg('Cannot sync with pulseoximeter, press next to retry!','Cannot sync','modal');
%            fclose(s);
            return;
        else         
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
        end
    end   
    h=waitbar(0,'Running');
    global start_message;
%     wavplay(start_message,48000,'async');
    
    InitializePsychSound(1);
    % Open the audio player with freq and nrchannels (2 for stereo)
    nrchannels = 2;
    freq = 48000;
    repetitions = 1;
    pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
    % make the tone, add to the player
    wavedata = [start_message' ; start_message'];
    PsychPortAudio('FillBuffer', pahandle, wavedata)
%     PsychPortAudio('Start', pahandle, 1, 0, 1);
    PsychPortAudio('Stop', pahandle, 1, 0, 1);

    %sound(start_message,48000); %** note 'sound' is always async. %**
    while s.BytesAvailable>5 fread(s,5,'uchar'); end;
    tic;
    mt_beats=0;
    tmp=toc;
    tmp2=0;
    global mt_task_beatscnt;
    global mt_task_hracc;
    global mt_task_hrsqacc;
    global mt_task_blk_beatscnt;
    global mt_task_blk_hracc;
    global mt_task_blk_hrsqacc;
    mt_task_blk_beatscnt=0;
    mt_task_blk_hracc=0;
    mt_task_blk_hrsqacc=0;
    previous_beat=0;
    while s.BytesAvailable>5 fread(s,5,'uchar'); end;
    while toc<block_duration
        buff=cast(fread(s,5,'uchar'),'uint8');
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
            if toc-tmp>1
                waitbar(toc/block_duration,h);
                tmp=toc;
            end        
            if sum(bitget(buff(2),4:7))>0
                errordlg(sprintf('Sensor problem, press next to retry!'),'Sensor problem','modal');
%                fclose(s);        
                close(h);
                return;
            elseif sum(bitget(buff(2),2:3))>0
                if ~previous_beat
                    previous_beat=1;
                    if mt_beats>0
                        mt_task_beatscnt=mt_task_beatscnt+1;
                        mt_task_hracc=mt_task_hracc+(60/(toc-tmp2));
                        mt_task_hrsqacc=mt_task_hrsqacc+(60/(toc-tmp2))^2;
                        mt_task_blk_beatscnt=mt_task_blk_beatscnt+1;
                        mt_task_blk_hracc=mt_task_blk_hracc+(60/(toc-tmp2));
                        mt_task_blk_hrsqacc=mt_task_blk_hrsqacc+(60/(toc-tmp2))^2;
                    end
                    mt_beats=mt_beats+1;           %increment beat count         
                    tmp2=toc;
                end
            else
                previous_beat=0;
            end                
        else
            errordlg(sprintf('Loss of sync, press next to retry!'),'Loss of sync','modal');
%            fclose(s);        
            close(h);
            return;        
        end
    end
    global stop_message;
    %     wavplay(stop_message,48000,'async');
    
    InitializePsychSound(1);
    % Open the audio player with freq and nrchannels (2 for stereo)
    nrchannels = 2;
    freq = 48000;
    repetitions = 1;
    pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
    % make the tone, add to the player
    wavedata = [stop_message' ; stop_message'];
    PsychPortAudio('FillBuffer', pahandle, wavedata)
%     PsychPortAudio('Start', pahandle, 1, 0, 1);
    PsychPortAudio('Stop', pahandle, 1, 0, 1);
    
    %sound(stop_message,48000); %**
    PsychPortAudio('Close', pahandle);
    close(h);
    f=0;
    return;

% --- Executes on button press in pushbutton11 (mental tracking, full task)
function pushbutton11_Callback(hObject, eventdata, handles)
    global mt_task_beatscnt; %beats count
    global mt_task_hracc; %heart rate accuracy
    global mt_task_hrsqacc; %heart rate square accuary
    global fid; %file identifier
    global mt_task_blockno; %block number
    global mt_task_vector;
    global s;
    global mt_task_last_written;
    global mt_task_accvector;    
    if strcmp(get(handles.pushbutton11,'String'),'Begin')
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton11,'String','Abort');
        set(handles.pushbutton9,'Enable','off');
        set(handles.pushbutton12,'Enable','off');
        set(handles.pushbutton10,'Enable','off');
        set(handles.edit19,'Enable','off');
        set(handles.edit19,'String','');
        set(handles.edit20,'Enable','off');
        set(handles.edit20,'String','');
%       durations=[5 4 6 8 3 5];
%       for testing only
        durations=[25 30 35 40 45 50]; %tracking durations (seconds)
        [b,i]=sort(rand(1,6)); 
        mt_task_vector=durations(i); %randomise durations
        mt_task_accvector=[];
        mt_task_blockno=1;
        s=serial(get(handles.edit10,'String'),'BaudRate',9600,'DataBits',8);
        fopen(s);
        fprintf(fid,'\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');       
        fprintf(fid,'            Heartbeat tracking task\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');       
        fprintf(fid,'\r\n');
        h=waitbar(0,'Syncing and calibrating...');
        buff=zeros(1,5,'uint8');
        sync_ok=0;
        tic;
        while ~sync_ok
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];      
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
                sync_ok=1;
            elseif toc>5
                errordlg('Cannot sync with pulseoximeter, task aborted!','Cannot sync','modal');
                fprintf(fid,'Aborted!\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'-----------------------------------------------\r\n');                  
                fclose(s);        
                close(h);
                set(handles.pushbutton9,'Enable','on');
                set(handles.pushbutton11,'String','Begin');
                set(handles.pushbutton11,'Enable','on');            
                return;
            end
        end
        waitbar(0.33,h);
        buff=cast(fread(s,5,'uchar'),'uint8')';
        sync_ok=0;
        tic;
        while ~sync_ok
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
                sync_ok=1;
            elseif toc>5
                errordlg('Cannot sync with pulseoximeter, task aborted!','Cannot sync','modal');
                fprintf(fid,'Aborted!\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'-----------------------------------------------\r\n');                  
                fclose(s);        
                close(h);
                set(handles.pushbutton9,'Enable','on');
                set(handles.pushbutton11,'String','Begin');
                set(handles.pushbutton11,'Enable','on');            
                return;
            else         
                buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
            end
        end
        waitbar(0.66,h);
        buff=cast(fread(s,5,'uchar'),'uint8')';
        sync_ok=0;
        tic;
        while ~sync_ok
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
                sync_ok=1;
            elseif toc>5
                errordlg('Cannot sync with pulseoximeter, task aborted!','Cannot sync','modal');
                fprintf(fid,'Aborted!\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'-----------------------------------------------\r\n');                  
                fclose(s);      
                close(h);
                set(handles.pushbutton9,'Enable','on');
                set(handles.pushbutton11,'String','Begin');
                set(handles.pushbutton11,'Enable','on');            
                return;
            else         
                buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
            end
        end
        close(h);
        mt_task_beatscnt=0;
        mt_task_hracc=0;
        mt_task_hrsqacc=0;
        if mt_task_do_block(mt_task_vector(mt_task_blockno))==0
            set(handles.pushbutton12,'Enable','on');
            set(handles.edit20,'Enable','on');
            set(handles.edit20,'String','');
            set(handles.edit19,'Enable','inactive');
            set(handles.edit19,'String',sprintf('%d',mt_task_blockno));
            mt_task_blockno=mt_task_blockno+1;
            mt_task_last_written=0;
            return;
        else
            fprintf(fid,'Problem during first block, task aborted!\r\n');
            fprintf(fid,'\r\n');
            fprintf(fid,'-----------------------------------------------\r\n');
            fclose(s);
            set(handles.pushbutton9,'Enable','on');
            set(handles.pushbutton11,'Enable','on');
            set(handles.pushbutton11,'String','Begin');
            return;
        end
    else
        fprintf(fid,'Task aborted by user!\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');
        fclose(s);
        set(handles.pushbutton10,'Enable','off');
        set(handles.radiobutton1,'Enable','off');
        set(handles.radiobutton3,'Enable','off');
        set(handles.edit17,'Enable','off');
        set(handles.edit17,'String','');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton11,'String','Begin');
        set(handles.pushbutton12,'Enable','off');
        set(handles.edit20,'Enable','off');
        set(handles.edit20,'String','');
        set(handles.edit19,'Enable','off');
        set(handles.edit19,'String','');
        return;
    end
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global mt_beats;
    global mt_task_vector;
    global mt_task_blockno;
    global s;
    global fid;
    global mt_task_beatscnt;
    global mt_task_hracc;
    global mt_task_hrsqacc;
    global mt_task_last_written;
    global mt_task_blk_beatscnt;
    global mt_task_blk_hracc;
    global mt_task_blk_hrsqacc;
    global mt_task_accvector;
    set(handles.pushbutton12,'Enable','off');
    set(handles.edit20,'Enable','off');
    if mt_task_blockno==length(mt_task_vector)+1
        acc=1-(abs(mt_beats-str2double(get(handles.edit20,'String')))/mean([mt_beats str2double(get(handles.edit20,'String'))]));
        fprintf(fid,'Block %d: Duration: %d s Recorded beats: %d Reported beats: %d Score: %.2f (%.1f,%.1f) \r\n',mt_task_blockno-1,mt_task_vector(mt_task_blockno-1),mt_beats,str2double(get(handles.edit20,'String')),acc,mt_task_blk_hracc/mt_task_blk_beatscnt,sqrt((mt_task_blk_hrsqacc-mt_task_blk_beatscnt*(mt_task_blk_hracc/mt_task_blk_beatscnt)^2)/mt_task_blk_beatscnt));
        mt_task_accvector=[mt_task_accvector,acc];
        fprintf(fid,'\r\n');
        fprintf(fid,'Average score %.2f\r\n',mean(mt_task_accvector));
        fprintf(fid,'\r\n');
        fprintf(fid,'Average heart rate (bpm) %.1f\r\n',mt_task_hracc/mt_task_beatscnt);
        fprintf(fid,'SD heart rate (bpm) %.1f\r\n',sqrt((mt_task_hrsqacc-mt_task_beatscnt*(mt_task_hracc/mt_task_beatscnt)^2)/mt_task_beatscnt));
        fprintf(fid,'\r\n');       
        fprintf(fid,'-----------------------------------------------\r\n');
        fclose(s);
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton12,'Enable','off');
        set(handles.edit20,'Enable','off');
        set(handles.edit20,'String','');
        set(handles.edit19,'Enable','off');
        set(handles.edit19,'String','');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton11,'String','Begin');
        set(handles.pushbutton12,'String','Next block');
        return;
    elseif mt_task_blockno>1
        if ~mt_task_last_written
            acc=1-(abs(mt_beats-str2double(get(handles.edit20,'String')))/mean([mt_beats str2double(get(handles.edit20,'String'))]));
            fprintf(fid,'Block %d: Duration: %d s Recorded beats: %d Reported beats: %d Score: %.2f (%.1f,%.1f) \r\n',mt_task_blockno-1,mt_task_vector(mt_task_blockno-1),mt_beats,str2double(get(handles.edit20,'String')),acc,mt_task_blk_hracc/mt_task_blk_beatscnt,sqrt((mt_task_blk_hrsqacc-mt_task_blk_beatscnt*(mt_task_blk_hracc/mt_task_blk_beatscnt)^2)/mt_task_blk_beatscnt));
            mt_task_accvector=[mt_task_accvector,acc];
            mt_task_last_written=1;
        end
        if mt_task_do_block(mt_task_vector(mt_task_blockno))==0
            set(handles.pushbutton12,'Enable','on');
            set(handles.edit20,'Enable','on');
            set(handles.edit20,'String','');
            set(handles.edit19,'Enable','inactive');
            set(handles.edit19,'String',sprintf('%d',mt_task_blockno));
            mt_task_blockno=mt_task_blockno+1;
            mt_task_last_written=0;
            if mt_task_blockno==length(mt_task_vector)+1
                set(handles.pushbutton12,'String','Finish');
            end            
            return;
        else
            set(handles.pushbutton12,'Enable','on');
        end
    else
        fprintf(fid,'Aborted!\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');
        fclose(s);
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton12,'Enable','off');
        set(handles.edit20,'Enable','off');
        set(handles.edit20,'String','');
        set(handles.edit19,'Enable','off');
        set(handles.edit19,'String','');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton11,'String','Begin');
        return;        
    end


function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.pushbutton8,'Enable','on');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
    fclose all;
    delete(hObject);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton10.
function pushbutton10_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%     global tt_sec;
    global tt_task_hrsqacc;
    global tt_task_blk_hracc;
    global tt_task_vector;
    global tt_task_blockno;
    global tt_task_blk_beatscnt;
    global tt_task_beatscnt;
    global tt_task_hracc;
    global tt_task_blk_hrsqacc; 
    global s;
    global fid;
%     global tt_task_seccnt;
%     global tt_task_secacc;
%     global tt_task_secsqacc;
    global tt_task_last_written;
%     global tt_task_blk_seccnt;
%     global tt_task_blk_secacc;
%     global tt_task_blk_secsqacc;
    global tt_task_accvector;
    set(handles.pushbutton17,'Enable','off');
    set(handles.edit27,'Enable','off');
    if tt_task_blockno==length(tt_task_vector)+1
        acc=1-(abs((tt_task_vector(tt_task_blockno-1))-str2double(get(handles.edit27,'String')))/mean([tt_task_vector(tt_task_blockno-1) str2double(get(handles.edit27,'String'))]));
        fprintf(fid,'Block %da: Duration: %d s Recorded seconds: %d Reported seconds: %d Score: %.2f (%.1f,%.1f) \r\n',tt_task_blockno-1,tt_task_vector(tt_task_blockno-1),(tt_task_vector(tt_task_blockno-1)),str2double(get(handles.edit27,'String')),acc,tt_task_blk_hracc/tt_task_blk_beatscnt,sqrt((tt_task_blk_hrsqacc-tt_task_blk_beatscnt*(tt_task_blk_hracc/tt_task_blk_beatscnt)^2)/tt_task_blk_beatscnt));
       tt_task_accvector=[tt_task_accvector,acc];
        fprintf(fid,'\r\n');
        fprintf(fid,'Average score %.2f\r\n',mean(tt_task_accvector));
        fprintf(fid,'\r\n');
        fprintf(fid,'Average heart rate (bpm) %.1f\r\n',tt_task_hracc/tt_task_beatscnt);
        fprintf(fid,'SD heart rate (bpm) %.1f\r\n',sqrt((tt_task_hrsqacc-tt_task_beatscnt*(tt_task_hracc/tt_task_beatscnt)^2)/tt_task_beatscnt));
        fprintf(fid,'\r\n');       
        fprintf(fid,'-----------------------------------------------\r\n');
        fclose(s);
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton16,'Enable','on');
        set(handles.pushbutton17,'Enable','off');
        set(handles.edit27,'Enable','off');
        set(handles.edit27,'String','');
        set(handles.edit26,'Enable','off');
        set(handles.edit26,'String','');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton16,'Enable','on');
        set(handles.pushbutton16,'String','Begin');
        set(handles.pushbutton17,'String','Next trial'); %changed from next block to next trial
        return;
    elseif tt_task_blockno>1
        if ~tt_task_last_written
            acc=1-(abs((tt_task_vector(tt_task_blockno-1))-str2double(get(handles.edit27,'String')))/mean([(tt_task_vector(tt_task_blockno-1)) str2double(get(handles.edit27,'String'))]));
            fprintf(fid,'Block_tt %d: Duration: %d s Recorded seconds: %d Reported seconds: %d Score: %.2f (%.1f,%.1f) \r\n',tt_task_blockno-1,tt_task_vector(tt_task_blockno-1),(tt_task_vector(tt_task_blockno-1)),str2double(get(handles.edit27,'String')),acc,tt_task_blk_hracc/tt_task_blk_beatscnt,sqrt((tt_task_blk_hrsqacc-tt_task_blk_beatscnt*(tt_task_blk_hracc/tt_task_blk_beatscnt)^2)/tt_task_blk_beatscnt));
            tt_task_accvector=[tt_task_accvector,acc];
            tt_task_last_written=1;
        end
        if tt_task_do_block(tt_task_vector(tt_task_blockno))==0
            set(handles.pushbutton17,'Enable','on');
            set(handles.edit27,'Enable','on');
            set(handles.edit27,'String','');
            set(handles.edit26,'Enable','inactive');
            set(handles.edit26,'String',sprintf('%d',tt_task_blockno));
            tt_task_blockno=tt_task_blockno+1;
            tt_task_last_written=0;
            if tt_task_blockno==length(tt_task_vector)+1
                set(handles.pushbutton17,'String','Finish');
            end            
            return;
        else
            set(handles.pushbutton17,'Enable','on');
        end
    else
        fprintf(fid,'Aborted!\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');
        fclose(s);
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton16,'Enable','on');
        set(handles.pushbutton17,'Enable','off');
        set(handles.edit27,'Enable','off');
        set(handles.edit27,'String','');
        set(handles.edit26,'Enable','off');
        set(handles.edit26,'String','');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton16,'Enable','on');
        set(handles.pushbutton16,'String','Begin');
        return;        
    end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton16. %%Begin Button
function pushbutton16_Callback(hObject, eventdata, handles)  
    global tt_task_seccnt;
    global tt_task_secacc;
    global tt_task_secsqacc;
    global fid;
    global tt_task_blockno;
    global tt_task_vector;
    global s;
    global tt_task_last_written;
    global tt_task_accvector;    
    global tt_task_beatscnt; %beats count
    global tt_task_hracc; %heart rate accuracy
    global tt_task_hrsqacc; %heart rate square accuary
    if strcmp(get(handles.pushbutton16,'String'),'Begin')
        set(handles.pushbutton16,'Enable','on');
        set(handles.pushbutton16,'String','Abort');
        set(handles.pushbutton17,'Enable','off');
        set(handles.edit26,'Enable','off');
        set(handles.edit26,'String','');
        set(handles.edit27,'Enable','off');
        set(handles.edit27,'String','');
%       durations=[5 4 6 8 3 5];
%       for testing only
        durations=[25 30 35 40 45 50]; %tracking durations (seconds)
        [b,i]=sort(rand(1,6)); 
        tt_task_vector=durations(i); %randomise durations
        tt_task_accvector=[];
        tt_task_blockno=1;
        s=serial(get(handles.edit10,'String'),'BaudRate',9600,'DataBits',8);
        fopen(s);
        fprintf(fid,'\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');       
        fprintf(fid,'            Time tracking task\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');       
        fprintf(fid,'\r\n');
        h=waitbar(0,'Syncing and calibrating...');
        buff=zeros(1,5,'uint8');
        sync_ok=0;
        tic;
        while ~sync_ok
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];      
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
                sync_ok=1;
            elseif toc>5
                errordlg('Cannot sync with pulseoximeter, task aborted!','Cannot sync','modal');
                fprintf(fid,'Aborted!\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'-----------------------------------------------\r\n');                  
                fclose(s);        
                close(h);
                set(handles.pushbutton9,'Enable','on');
                set(handles.pushbutton11,'String','Begin');
                set(handles.pushbutton11,'Enable','on');            
                return;
            end
        end
        waitbar(0.33,h);
        buff=cast(fread(s,5,'uchar'),'uint8')';
        sync_ok=0;
        tic;
        while ~sync_ok
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
                sync_ok=1;
            elseif toc>5
                errordlg('Cannot sync with pulseoximeter, task aborted!','Cannot sync','modal');
                fprintf(fid,'Aborted!\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'-----------------------------------------------\r\n');                  
                fclose(s);        
                close(h);
                set(handles.pushbutton9,'Enable','on');
                set(handles.pushbutton11,'String','Begin');
                set(handles.pushbutton11,'Enable','on');            
                return;
            else         
                buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
            end
        end
        waitbar(0.66,h);
        buff=cast(fread(s,5,'uchar'),'uint8')';
        sync_ok=0;
        tic;
        while ~sync_ok
            if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
                sync_ok=1;
            elseif toc>5
                errordlg('Cannot sync with pulseoximeter, task aborted!','Cannot sync','modal');
                fprintf(fid,'Aborted!\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'-----------------------------------------------\r\n');                  
                fclose(s);      
                close(h);
                set(handles.pushbutton9,'Enable','on');
                set(handles.pushbutton11,'String','Begin');
                set(handles.pushbutton11,'Enable','on');            
                return;
            else         
                buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
            end
        end
        close(h);
        tt_task_seccnt=0;
        tt_task_secacc=0;
        tt_task_secsqacc=0;
        tt_task_beatscnt=0;
        tt_task_hracc=0;
        tt_task_hrsqacc=0;
        if tt_task_do_block(tt_task_vector(tt_task_blockno))==0
            set(handles.pushbutton17,'Enable','on');
            set(handles.edit27,'Enable','on');
            set(handles.edit27,'String','');
            set(handles.edit26,'Enable','inactive');
            set(handles.edit26,'String',sprintf('%d',tt_task_blockno));
            tt_task_blockno=tt_task_blockno+1;
            tt_task_last_written=0;
            return;
        else
            fprintf(fid,'Problem during first block, task aborted!\r\n');
            fprintf(fid,'\r\n');
            fprintf(fid,'-----------------------------------------------\r\n');
            fclose(s);
            set(handles.pushbutton16,'Enable','on');
            set(handles.pushbutton16,'String','Begin');
            return;
        end
    else
        fprintf(fid,'Task aborted by user!\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'-----------------------------------------------\r\n');
        fclose(s);
        set(handles.pushbutton10,'Enable','off');
        set(handles.radiobutton1,'Enable','off');
        set(handles.radiobutton3,'Enable','off');
        set(handles.edit17,'Enable','off');
        set(handles.edit17,'String','');
        set(handles.pushbutton9,'Enable','on');
        set(handles.pushbutton16,'Enable','on');
        set(handles.pushbutton16,'String','Begin');
        set(handles.pushbutton17,'Enable','off');
        set(handles.edit27,'Enable','off');
        set(handles.edit27,'String','');
        set(handles.edit26,'Enable','off');
        set(handles.edit26,'String','');
        return;
    end
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function f=tt_task_do_block(block_duration) %mental tracking task routine
    global s;
    f=-1;
    global tt_beats;
    tt_beats=-1;
    global tt_sec;
    tt_sec=-1;
    while s.BytesAvailable>5 fread(s,5,'uchar'); end;
    buff=zeros(1,5,'uint8');
    sync_ok=0;
    tic;
    while ~sync_ok
        buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];      
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
            sync_ok=1;
        elseif toc>5
            errordlg('Cannot sync with pulseoximeter, press next to retry!','Cannot sync','modal');
%            fclose(s);
            return;
        end
    end
    buff=cast(fread(s,5,'uchar'),'uint8')';
    sync_ok=0;
    tic;
    while ~sync_ok
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
            sync_ok=1;
        elseif toc>5
            errordlg('Cannot sync with pulseoximeter, press next to retry!','Cannot sync','modal');
%            fclose(s);
            return;
        else         
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
        end
    end   
    buff=cast(fread(s,5,'uchar'),'uint8')';
    sync_ok=0;
    tic;
    while ~sync_ok
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0        
            sync_ok=1;
        elseif toc>5
            errordlg('Cannot sync with pulseoximeter, press next to retry!','Cannot sync','modal');
%            fclose(s);
            return;
        else         
            buff=[buff(2:5),cast(fread(s,1,'uchar'),'uint8')];
        end
    end   
    h=waitbar(0,'Running');
    global start_message;
%     wavplay(start_message,48000,'async');
    
    InitializePsychSound(1);
    % Open the audio player with freq and nrchannels (2 for stereo)
    nrchannels = 2;
    freq = 48000;
    repetitions = 1;
    pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
    % make the tone, add to the player
    wavedata = [start_message' ; start_message'];
    PsychPortAudio('FillBuffer', pahandle, wavedata)
%     PsychPortAudio('Start', pahandle, 1, 0, 1);
    PsychPortAudio('Stop', pahandle, 1, 0, 1);
    
    %sound(start_message,48000); %** note 'sound' is always async. %**
    while s.BytesAvailable>5 fread(s,5,'uchar'); end;
    tic;
    tt_beats=0;
    tt_sec=0;
    tmp=toc;
    tmp2=0;
    global tt_task_beatscnt;
    global tt_task_hracc;
    global tt_task_hrsqacc;
    global tt_task_blk_beatscnt;
    global tt_task_blk_hracc;
    global tt_task_blk_hrsqacc;
    global tt_task_seccnt;
    global tt_task_secacc;
    global tt_task_secsqacc;
    global tt_task_blk_seccnt;
    global tt_task_blk_secacc;
    global tt_task_blk_secsqacc;
    tt_task_blk_seccnt=0;
    tt_task_blk_secacc=0;
    tt_task_blk_secsqacc=0;
    tt_task_blk_beatscnt=0;
    tt_task_blk_hracc=0;
    tt_task_blk_hrsqacc=0;
    previous_beat=0;
    while s.BytesAvailable>5 fread(s,5,'uchar'); end;
    while toc<block_duration
        buff=cast(fread(s,5,'uchar'),'uint8');
        if sum(bitget(buff(1),2:8))==0&&sum(bitget(buff(1),1))==1&&sum(bitget(buff(2),8))==1&&(bitand(sum(buff(1:4)),255)-buff(5))==0
            if toc-tmp>1
                waitbar(toc/block_duration,h);
                tmp=toc;
            end        
            if sum(bitget(buff(2),4:7))>0
                errordlg(sprintf('Sensor problem, press next to retry!'),'Sensor problem','modal');
%                fclose(s);        
                close(h);
                return;
            elseif sum(bitget(buff(2),2:3))>0
                if ~previous_beat
                    previous_beat=1;
                    if tt_beats>0
                        tt_task_beatscnt=tt_task_beatscnt+1;
                        tt_task_hracc=tt_task_hracc+(60/(toc-tmp2));
                        tt_task_hrsqacc=tt_task_hrsqacc+(60/(toc-tmp2))^2;
                        tt_task_blk_beatscnt=tt_task_blk_beatscnt+1;
                        tt_task_blk_hracc=tt_task_blk_hracc+(60/(toc-tmp2));
                        tt_task_blk_hrsqacc=tt_task_blk_hrsqacc+(60/(toc-tmp2))^2;
                        tt_task_seccnt=tt_task_seccnt+1;
                        tt_task_secacc=tt_task_secacc+(60/(toc-tmp2));
                        tt_task_secsqacc=tt_task_secsqacc+(60/(toc-tmp2))^2;
                        tt_task_blk_seccnt=tt_task_blk_seccnt+1;
                        tt_task_blk_secacc=tt_task_blk_secacc+(60/(toc-tmp2));
                        tt_task_blk_secsqacc=tt_task_blk_secsqacc+(60/(toc-tmp2))^2;
                    end
                    tt_beats=tt_beats+1;           %increment beat count  
                    tt_sec=tt_sec+1;
                    tmp2=toc;
                end
            else
                previous_beat=0;
            end                
        else
            errordlg(sprintf('Loss of sync, press next to retry!'),'Loss of sync','modal');
%            fclose(s);        
            close(h);
            return;        
        end
    end
    global stop_message;
%     wavplay(stop_message,48000,'async');
    
    InitializePsychSound(1);
    % Open the audio player with freq and nrchannels (2 for stereo)
    nrchannels = 2;
    freq = 48000;
    repetitions = 1;
    pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
    % make the tone, add to the player
    wavedata = [stop_message' ; stop_message'];
    PsychPortAudio('FillBuffer', pahandle, wavedata)
%     PsychPortAudio('Start', pahandle, 1, 0, 1);
    PsychPortAudio('Stop', pahandle, 1, 0, 1);

    %sound(stop_message,48000); %**
    PsychPortAudio('Close', pahandle);
    close(h);
    f=0;
    return;


% --- Executes during object creation, after setting all properties.
function text20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



