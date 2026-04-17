% Parsa Khodabandehlou
% pkhodab@ncsu.edu
% Apr 16th 2026
% PA8P2_KHODABANDEHLOU.m
%
% Records video of a bouncing ball and calculates motion, bounce heights,
% coefficient of restitution, and energy.

clear
close all
clc

%% Declarations
% Constants
G = -9.81;               % gravity (m/s^2)

% Ball properties (provided for PA8P2)
ballMass = 0.051;        % ball mass (kg), 51 g
ballDm = 100e-3;         % known ball diameter (m), 100 mm

% Video setup
vidFile = 'BB2A.mov';
vid = VideoReader(vidFile);
frameRate = 120;         % use known/assigned frame rate (fps)

% Frame range (trim unusable beginning/end)
frameStart = 40;                % change if needed
frameStop = 292;               % change if needed
frameList = frameStart:frameStop;
numFrames = numel(frameList);

% Color threshold (RGB)
Cmin = [120, 50, 50];
Cmax = [255, 255, 255];

% Use the full frame (no cropping)
cropW = 260;
cropH = 678;

% Bounce detection settings
minPeakDistSec = 0.10;   % minimum time between bounce peaks (s)
peakPromFrac = 0.03;     % prominence as fraction of max height
minHeightFrac = 0.08;    % minimum normalized height for "quality" bounces

%% Section 1: Process each frame (full frame, threshold, centroid)
centRow = zeros(numFrames,1);
centCol = zeros(numFrames,1);
ballAreaPx = zeros(numFrames,1);
hasCentroid = false(numFrames,1);
firstCentCol = 0;           % anchor x so initial detected position is x = 0
hasFirstCentCol = false;
trajXLim = [0, cropW - 1];  % updated once first centroid is detected

figure('Name','Motion Tracking','Color','w')
for n = 1:numFrames
    k = frameList(n);

    % Read one frame (no cropping)
    frameRGB = read(vid, k);
    frameCrop = frameRGB;

    % Binary threshold for the ball color
    BW = ~(frameCrop(:,:,1) >= Cmin(1) & frameCrop(:,:,1) <= Cmax(1) & ...
         frameCrop(:,:,2) >= Cmin(2) & frameCrop(:,:,2) <= Cmax(2) & ...
         frameCrop(:,:,3) >= Cmin(3) & frameCrop(:,:,3) <= Cmax(3));
    
    % Centroid of thresholded blob
    [r, c] = Centroid(BW);
    if r > 0 && c > 0
        centRow(n) = r;
        centCol(n) = c;
        ballAreaPx(n) = sum(BW(:));
        hasCentroid(n) = true;
    end

    % Plot 1: binary image
    subplot(1,2,1)
    imshow(BW)
    title('Binary Image')

    % Plot 2: centroid history + current location
    subplot(1,2,2)
    if hasCentroid(n) && ~hasFirstCentCol
        firstCentCol = centCol(n);
        hasFirstCentCol = true;
    end

    xHist = centCol(1:n) - firstCentCol; % x=0 at first detected centroid
    yHist = cropH - centRow(1:n) + 1; % upward-positive plotting
    valid = hasCentroid(1:n);

    % Keep trajectory axes in pixel units but aligned to x=0 at release:
    % left limit is pixels available to the left edge, right limit to the right edge.
    trajXLim = [-(firstCentCol - 1), (cropW - firstCentCol)];

    plot(xHist(valid), yHist(valid), 'b-', 'LineWidth', 1.4)
    hold on
    lastIdx = find(valid, 1, 'last');
    plot(xHist(lastIdx), yHist(lastIdx), 'rx', 'LineWidth', 1.8, 'MarkerSize', 9)
    hold off
    grid on
    xlim(trajXLim)
    ylim([0 cropH])
    pbaspect([cropW cropH 1])
    set(gca, 'YDir', 'normal')
    title('Centroid Trajectory')
    xlabel('x (pixels)')
    ylabel('y (pixels, upward)')

    drawnow
end

%% Pixel-to-meter conversion from measured diameter
validArea = ballAreaPx > 0;
ballDPxVec = sqrt(4*ballAreaPx(validArea)/pi);   % equivalent diameter from area
ballDPx = median(ballDPxVec);                    % one scale for whole video
px2m = ballDm / ballDPx;

%% Section 2: Kinematics (position, velocity, acceleration)
% Fill missing centroid values from occasional threshold dropouts
knownRows = find(hasCentroid);

centRowFilled = centRow;
firstKnown = knownRows(1);
lastKnown = knownRows(end);
centRowFilled(1:firstKnown-1) = centRow(firstKnown);
centRowFilled(lastKnown+1:end) = centRow(lastKnown);


% y position in meters: positive and ends at zero (ground)
yPosPx = cropH - centRowFilled + 1;
yPosM = yPosPx * px2m;
yCorr = yPosM - yPosM(end);
ySmooth = smooth(yCorr, 5);

% Time vector for analyzed frames
t = (0:numFrames-1)' / frameRate;

% Numerical derivatives
yVel = gradient(ySmooth, t);
yAcc = gradient(yVel, t);

figure('Name','Kinematics','Color','w')
subplot(3,1,1)
plot(t, yCorr, 'Color', [0.75 0.75 0.75], 'LineWidth', 1)
hold on
plot(t, ySmooth, 'b-', 'LineWidth', 1.5)
hold off
grid on
xlabel('Time (s)')
ylabel('y (m)')
title('Vertical Position')
legend('Corrected y', 'Smoothed y', 'Location', 'best')

subplot(3,1,2)
plot(t, yVel, 'r-', 'LineWidth', 1.3)
grid on
xlabel('Time (s)')
ylabel('v_y (m/s)')
title('Vertical Velocity')

subplot(3,1,3)
plot(t, yAcc, 'm-', 'LineWidth', 1.3)
hold on
yline(G, 'k--', 'g')
hold off
grid on
xlabel('Time (s)')
ylabel('a_y (m/s^2)')
title('Vertical Acceleration')

%% Section 3: Bounce heights and coefficient of restitution
minPeakDistFrames = round(minPeakDistSec * frameRate);
minProminence = peakPromFrac * max(ySmooth);

% Rebound maxima after each impact
[reboundHeights, reboundLocs] = findpeaks(ySmooth, ...
    'MinPeakDistance', minPeakDistFrames, ...
    'MinPeakProminence', minProminence);

% Include release height as bounce number 0
hAll = [ySmooth(1); reboundHeights(:)];
bounceNumAll = (0:numel(hAll)-1)';

figure('Name','Bounce Heights','Color','w')
st = stem(bounceNumAll, hAll, 'filled', 'LineWidth', 1.2, 'MarkerSize', 6);
grid on
xlabel('Bounce Number')
ylabel('Height (m)')
title('Initial and Rebound Heights')

% e_n = sqrt(h_(n+1)/h_n)
eEach = sqrt(hAll(2:end) ./ hAll(1:end-1));

% Keep "quality" bounces only (ignore tiny/noisy late bounces)
qualityMask = hAll(2:end) >= minHeightFrac * hAll(1);
eQuality = eEach(qualityMask);

eMean = mean(eQuality);

fprintf('Average coefficient of restitution: %.4f\n', eMean)

%% Section 4: Energy vs time
PE = ballMass * abs(G) .* ySmooth;
KE = 0.5 * ballMass .* (yVel.^2);
TE = PE + KE;

figure('Name','Energy','Color','w')
plot(t, PE, 'g-', 'LineWidth', 1.3)
hold on
plot(t, KE, 'b-', 'LineWidth', 1.3)
plot(t, TE, 'k-', 'LineWidth', 1.6)
hold off
grid on
xlabel('Time (s)')
ylabel('Energy (J)')
title('Potential, Kinetic, and Total Energy')
legend('Potential Energy', 'Kinetic Energy', 'Total Energy', 'Location', 'best')
