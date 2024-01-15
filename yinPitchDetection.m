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