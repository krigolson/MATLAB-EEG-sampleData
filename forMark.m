clear all;
close all;
clc;

% load some data
EEG = doLoadBVData('/Users/olavekrigolson/Documents/GitHub/MATLAB-EEG-sampleData','Cognitive_Assessment_01.vhdr');

% filter the data
EEG = doFilter(EEG,0.1,30,2,60,500);

% epoch the data into 2 second chunks
EEG = doTemporalEpochs(EEG,1000,500);

% a counter for the coupling
counter = 1;

for i = 1:100
    
    % read in a chunk of data, just use first two channels to assume these
    % are the ones selected in peak alpha
    currentData = EEG.data(1:2,:,i);
    
    % run the FFT on the data, note my FFT returns phase which in MATLAB is
    % just the following "angle(FFTOUTPUT)" - angle is a MATLAB command
    % which is searchable
    [power phase freq] = doFourier(currentData, EEG.srate);
    
    %%% CLASSIC PEAK ALPHA
    
    % extract alpha
    % note, we decided lowerBound and upperBound were user parameters as
    % was the channel they pick
    lowerBound = 8;
    upperBound = 12;
    selectedChannel = 1;
    
    % extract alpha
    alphaPower = power(selectedChannel,lowerBound:upperBound);
    
    % find the largest peak alpha value
    [peakAlpha peakAlphaPosition] = max(alphaPower);
    
    % this is a correction as MATLAB returns the position relative to what
    % you are searching so I have to add the lowerBound to get the actual
    % frequency
    peakAlphaFrequency = lowerBound + peakAlphaPosition -1;
    
    %%% ALPHA ASYMETRY
    
    firstChannel = 1;
    secondChannel = 2;
    
    % literally subract the alpha power from the first channel from the
    % second channel
    alphaAsymmetry = power(secondChannel,lowerBound:upperBound) - power(firstChannel,lowerBound:upperBound);
    
    % find the largest peak alpha value
    [peakAlphaAssym peakAlphaPositionAssym] = max(alphaAsymmetry);
    
    % this is a correction as MATLAB returns the position relative to what
    % you are searching so I have to add the lowerBound to get the actual
    % frequency
    peakAlphaFrequencyAssym = lowerBound + peakAlphaPositionAssym -1;
    
    %%% ALPHA POWER COUPLING
    
    % the key here is you need at least N time points, I am using 30 but we
    % should make this a variable the user can choose
    
    N = 30;
    
    % stuff the data into a variable
    powers(:,:,counter) = power;
    phases(:,:,counter) = phase;
    counter = counter + 1;
    
    % ensure I only have the 30 most recent values
    if size(powers,3) > N
        % delete oldest value
        powers(:,:,1) = [];
        phases(:,:,1) = [];
        counter = N;
    end
    
    % compute power coupling
    
    powerData1 = squeeze(powers(firstChannel,peakAlphaFrequency,:));
    powerData2 = squeeze(powers(secondChannel,peakAlphaFrequency,:));
    
    powerCoupling = corr(powerData1,powerData2);

    % ALPHA PHASE COUPLING
    
    phaseData1 = squeeze(phases(firstChannel,peakAlphaFrequency,:));
    phaseData2 = squeeze(phases(secondChannel,peakAlphaFrequency,:));
    
    phaseCoupling = corr(phaseData1,phaseData2);
    
end
    
    
    