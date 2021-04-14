% Marius Mereckis
% Solar Eclipse Data Analysis
% spectrominutetones cleaned up and improved

close all; clear all; clc;
%
% grab .wav file from directory and list parameters form formatted filename
files = dir('*.wav');
for q = 1:size(files, 1)
filename = string(files(q).name);
audioinfo(filename);
parameters = regexp(erase(filename, '.wav'), '_', 'split');
parameters = parameters(~cellfun('isempty',parameters));

% get callsign from filename:
Call = string(parameters{1});
% contend with timezone
qux = [1:9 -70 1:3 -12:0];
slipnum = double(char(parameters{2})) - 64; 
slip = qux(slipnum);
% get date and time
foo = convertCharsToStrings(regexp(parameters{3}, '-', 'split'));
bar = convertCharsToStrings(regexp(parameters{4}, '-', 'split'));
SHIFT = hours(slip);
% set start time of recording
START = datetime([double(foo) double(bar)]) + SHIFT;

%read audio file, save in y along with sampling frequency
[y,Fs] = audioread(filename);

%
% retime .wav audio into second intervals
audio = timetable(y,'SampleRate', Fs);
retimedAudio = retime(audio, 'regular','mean', 'Timestep', seconds(1));
retimedAudio.Properties.StartTime = START;

% This is for frequencies centered around 1Khz
% fourier transform of audio signal using hilbert transform
instantaneousFrequencies = instfreq(y,Fs,'Method','hilbert');
% time table of frequencies
initFreqTable = timetable(instantaneousFrequencies, 'SampleRate', Fs);
% retime to 1 second intervals
freqTableRetimed = retime(initFreqTable,'regular','mean', 'Timestep', seconds(1));
% set start time to time that recording started
freqTableRetimed.Properties.StartTime = START;

% For frequencies in the range of interest [1400 1640] to encapsolate the
% 440hz, 500hz, and 600hz minute tones
t = (0:1/Fs:2-1/Fs);
% time resolution changes the number of samples, 1 gives resolution on the
% order of a few hundred milliseconds
[p,fd,td] = pspectrum(audio.y,audio.Time,'spectrogram','FrequencyLimits', [1400 1640], 'TimeResolution', 1);
[frequencies,times]=instfreq(p,fd,td); 
instfreq(p,fd,td);

% create time table for minute tone frequencies with time intervals
% given from instfreq (resolution of 100s of ms)
freqTable = timetable(frequencies, 'RowTimes', times);
freqTable.Properties.StartTime = START;

%
% arrays containing minutes at which specific tones are being transmitted

% add a collumn to time table containing the tone based on estimated freq
tones = tone(freqTable.frequencies,height(freqTable));
tonesTable = timetable(tones, 'RowTimes', times);
tonesTable.Properties.StartTime = START;
minuteToneFreqTable = [freqTable, tonesTable];

% classify the stationID belonging to each freq/tone estimate
stationID = strings(height(minuteToneFreqTable),1);
for i = 1:height(minuteToneFreqTable)
    stationID(i) = STATIONID(minuteToneFreqTable.Time(i),minuteToneFreqTable.tones(i));
end

stationTable = timetable(stationID, 'RowTimes', times);
stationTable.Properties.StartTime = START;

minuteToneFreqStationTable = [minuteToneFreqTable, stationTable];

display(minuteToneFreqStationTable)
% Add in callsign and save the table for future use
minuteToneFreqStationTable.Receiver(:) = Call;
writetimetable(minuteToneFreqStationTable, strcat('StationReport_', erase(filename, '.wav'), '.csv'));
end
%
% function for classifying tone based on frequency
 function t = tone(frequencies,height)
 tones = strings(height,1);
    
 for i = 1:height
    if frequencies(i) > 1470 & frequencies(i) < 1530
        tones(i) = "500 Hz Tone";
    end
 end
 for i = 1:height
    if frequencies(i) > 1570 & frequencies(i) < 1630
        tones(i) = "600 Hz Tone";
    end
 end
 for i = 1:height
    if frequencies(i) > 1410 & frequencies(i) < 1470
        tones(i) = "440 Hz Tone";
    end
 end
 t = tones;
 end

 function SID = STATIONID(time, tone)
WWV600 = [1,3,5,7,11,13,17,21,23,25,27,31,33,35,37,39,41,53,55,57];
WWV500 = [4,6,12,16,20,22,24,26,28,32,34,36,38,40,42,54,56,58];
WWV440 = [2];

WWVH600 = [2,4,6,12,20,22,24,26,28,32,34,36,38,40,42,46,52,54,56,58];
WWVH500 = [3,5,7,13,21,23,25,27,31,33,35,37,39,41,47,53,55,57];
WWVH440 = [1];

 ID = strings(1);
 currentTime = time.Minute;
 currentTone = tone;
 if ismember(currentTime,WWV440)
     if currentTone == "440 Hz Tone"
         ID = "WWV";
     end
 end
 if ismember(currentTime, WWV500)
     if currentTone == "500 Hz Tone"
         ID = "WWV";
     end
 end
 if ismember(currentTime, WWV600)
     if currentTone == "600 Hz Tone"
         ID = "WWV";
     end
 end
 if ismember(currentTime,WWVH440)
     if currentTone == "440 Hz Tone"
         ID = "WWVH";
     end
 end
 if ismember(currentTime, WWVH500)
     if currentTone == "500 Hz Tone"
         ID = "WWVH";
     end
 end
 if ismember(currentTime, WWVH600)
     if currentTone == "600 Hz Tone"
         ID = "WWVH";
     end
 end
 SID = ID;
 end
 
 
 
 

