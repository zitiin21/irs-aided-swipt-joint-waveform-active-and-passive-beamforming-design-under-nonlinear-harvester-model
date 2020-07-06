%% ! FS-IRS: R-E region by SDR
% * Initialize algorithm
[~, compositeChannel] = irs_fs(directChannel, incidentChannel, reflectiveChannel);
[capacity, infoWaveform_] = wit_fs(compositeChannel, txPower, noisePower);
[current, ~, powerWaveform_] = wpt_fs(beta2, beta4, tolerance, compositeChannel, txPower, nCandidates, noisePower);
rateConstraint = linspace((1 - tolerance) * capacity, 0, nSamples);

% * SDR
fsSdrSample = zeros(3, nSamples);
for iSample = 1 : nSamples
    % * Initialize waveform and splitting ratio for each sample
    infoWaveform = infoWaveform_;
    powerWaveform = powerWaveform_;

    % * AO
    isConverged = false;
    current_ = 0;
    while ~isConverged
        [infoRatio, powerRatio] = split_ratio(compositeChannel, noisePower, rateConstraint(iSample), infoWaveform);
        [infoWaveform, powerWaveform] = waveform_sdr(beta2, beta4, txPower, nCandidates, rateConstraint(iSample), tolerance, infoRatio, powerRatio, noisePower, compositeChannel, infoWaveform, powerWaveform);
        [rate, current] = re_sample(beta2, beta4, compositeChannel, noisePower, infoWaveform, powerWaveform, infoRatio, powerRatio);
        isConverged = abs(current - current_) / current <= tolerance || current <= 1e-10;
        current_ = current;
    end
    fsSdrSample(:, iSample) = [rate; current; powerRatio];
end
