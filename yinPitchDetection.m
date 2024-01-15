function pitch = yinPitchDetection(data, Fs)
    % function that implements YIN algorithm for fundamental pitch tracking

    win = length(data);  % Window size - Assuming data is already one frame length
    nframes = 1;  % Since data is treated as a single frame
    
    d = zeros(nframes, win);
    
    %%
    % Calculate difference function
    for tau = 0:win-1
        for j = 1:win-tau
             d(:, tau + 1) = d(:, tau + 1) + (data(j) - data(j + tau)).^2;         
        end
    end

    %%
    % Cumulative mean normalised difference function
    d_norm = zeros(nframes, win);
    d_norm(:, 1) = 1;
    
    for tau = 1:win-1
        d_norm(:, tau + 1) = d(:, tau + 1) / ((1/tau) * sum(d(:, 1:tau + 1)));
    end

    %%
    % Absolute thresholding
    lag = zeros(1, nframes);
    th = 0.1;
    
    for i = 1:nframes
        l = find(d_norm(i, :) < th, 1);
        if (isempty(l) == 1)
            [v, l] = min(d_norm(i, :));
        end
        lag(i) = l;
    end

    %%
    % Parabolic interpolation
    period = zeros(1, nframes);
    
    for i = 1:nframes
        if (lag(i) > 1 && lag(i) < win)
            alpha = d_norm(i, lag(i) - 1);
            beta = d_norm(i, lag(i));
            gamma = d_norm(i, lag(i) + 1);
            peak = 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma);
        else
            peak = 0;
        end
        period(i) = (lag(i) - 1) + peak;
    end

    pitch_0 = Fs / period;
    if pitch_0 < 130
        pitch = 0;
    else
        pitch = pitch_0;
    end
end



% step 4 - parabolic interpolation
% period = zeros(1,nframes);
% time = zeros(nframes,win);
% f0 = zeros(nframes,win);
% start = 1;
% 
% for i = 1:nframes
%     if(lag(i) > 1 && lag(i) < win)
%         alpha = d_norm(i,lag(i)-1);
%         beta = d_norm(i,lag(i));
%         gamma = d_norm(i,lag(i)+1);
%         peak = 0.5*(alpha - gamma)/(alpha - 2*beta + gamma);
%         ordinate needs to be calculated from d and not d_norm - see paper
%         ordinate = d(i,lag(i)) - 0.25*(d(i,lag(i)-1) - d(i,lag(i)+1))*peak;
%     else
%         peak = 0;
%     end
%     1 needs to be subtracted from 1 due to matlab's indexing nature
%     period(i) = (lag(i)-1) + peak;
%     f0(i,:) = fs/period(i)*ones(1,win);
%     time(i,:) = ((i-1)*win:i*win-1)/fs;
%     
% end
% 
% for silent frames estimated frequency should be 0Hz
% if ~isempty(varargin)
%     [f0] = silent_frame_classification(x_frame, f0);
% end
% 
% f0 = reshape(f0',1,nframes*win);
% time = reshape(time',1,nframes*win);
% 
% end