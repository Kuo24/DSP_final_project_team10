clc;
clear all

global SCORE;
global NUM;
global DIFF_TIME;
global FINAL;
SCORE = 0;
NUM = 0;
DIFF_TIME = 0;
FINAL = 0;

% Display text to choose the song
% music1: カメレオン, music2:僕という名のドラマ, music3:Cmon Cmon, 440Hz
disp('Please choose your song (music1: カメレオン, music2:僕という名のドラマ, music3:Cmon Cmon, 440Hz):');
chosen_song = input('Enter the name of the song: ', 's');

% Display loading message
disp('Loading...');

% Load music file
music_file = [chosen_song, '.mp3'];
[audio, Fs] = audioread(music_file);
duration = length(audio) / Fs;
disp(duration)

% Load existing pitch data from CSV file
global time_column_background;
global f0_background;
csv_file = [chosen_song, '_pitch_data.csv'];
df = readtable(csv_file);
f0_background = df.Frequency;
time_column_background = df.Time;

% Initialize DAQ
dq = daq("directsound");
addinput(dq,"Audio0",1,"Audio");

%%
%%%%%%%%%%%%%%%%%%%
% Create a real-time pitch plot with background
hf_pitch = figure;
hp_pitch_background = plot(time_column_background, f0_background, "_", 'color', [0 0 1]);
hold on;
hp_pitch = plot(0, 0, 'color','r','marker','_', 'LineWidth', 2);
hold off;
T_pitch = title('Real-time Pitch Contour');
xlabel('Time (s)')
ylabel('Frequency (Hz)')
ylim([0 ceil(max(f0_background)/100)*100]) %%測試用測試用測試用測試用測試用%%
grid on;
%%
%%%%%%%%%%%%%%%%%%%%%%%
% Initialize time at the beginning
start_time = tic;

% Set ScansAvailableFcn for pitch detection
dq.ScansAvailableFcn = @(src, evt) plotPitch(src, hp_pitch, start_time, duration);
% Start Acquisition for pitch detection
start(dq, "Duration", seconds(duration));
figure(hf_pitch);
sound(audio, Fs);
disp(SCORE)
disp(NUM)

function plotPitch(daqHandle, plotHandle, start_time, duration)
    global time_column_background;
    global f0_background;
    global NUM;
    global DIFF_TIME;
    % Read real-time data, perform pitch detection, and update the pitch plot.
    data = read(daqHandle, daqHandle.ScansAvailableFcnCount, "OutputFormat", "Matrix");
    Fs = daqHandle.Rate;
    
    % Update the pitch plot
    current_time = toc(start_time);
    if NUM == 0
        DIFF_TIME = current_time;
    end
    % Use YIN to detect real time pitch
    pitch = yinPitchDetection(data, Fs);

    % Find the nearest time point in the background pitch contour
    [~, index] = min(abs(time_column_background - (current_time-DIFF_TIME)));
    correct_pitch = f0_background(index);
    
    % Compare real-time pitch with correct pitch
    difference = abs(pitch - correct_pitch);
    calculate(difference)
    
    set(plotHandle, 'xdata', current_time-DIFF_TIME, 'ydata', pitch);
    drawnow

    % Check if the music has finished playing
    if current_time >= duration
        % Stop DAQ acquisition
        stop(daqHandle);
        final_score;
    end
end

function calculate(difference)
    global SCORE; 
    global NUM;
    if difference <= 10
        SCORE = SCORE +1;
        NUM = NUM + 1;
    elseif difference <=100
        SCORE = SCORE +(1-abs(log10(difference/10)));
        NUM = NUM +1;
    else
        NUM = NUM + 1;
    end
end

function final_score
    global SCORE; 
    global NUM;
    global FINAL;
    if FINAL == 0
        finalscore = 100*abs(1-log10(100 * (SCORE / NUM)));
        disp(['Final Score: ', num2str(finalscore)]);
        FINAL = FINAL + 1;
    end
end
