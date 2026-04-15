% Parsa Khodabandehlou
% pkhodab@ncsu.edu
% Apr 8th 2026
% PA8_KHODABANDEHLOU.m
%
% Records video of bouncing ball and calculates the energy and coefficient
% of restitution

clear
close all
clc 

%% Declarations
% You will probably add many more variables to this section. Remember:
% avoid numbers in later sections of your code, so include parameters
% like threshold limits, crop values, etc., in this section.

% Constant
G = -9.81; % gravity (m/s^2)

% Ball properties
ballMass = 0.1;    % ball mass (kg)
ballDm = 69.51e-3; % ball diameter (m)
ballDPx = [];      % ball diameter (px), computed from video
px2m = [];         % pixel-to-meter conversion factor, computed from video

% Load video
vidFile = 'ball.mov';
vid = VideoReader(vidFile); % reads in .avi file
frameRate = 240;  % frame rate (fps), pulled from video

% Video information
frameStart = 1; % CHANGE THIS
frameStop = getfield(vid, 'NumFrames'); % CHANGE THIS
frameIdx = (frameStart:frameStop).';
timeVec = (frameIdx - frameStart) / frameRate; 

% Color codes
Cmin = [129, 29, 7];
Cmax = [308, 223, 220];

% Crop points
xCrop = 393;
yCrop = 167;
yCropBot = 1300;
xCropBot = 1026;

% Step through each frame 
cropW = xCropBot - xCrop;
cropH = yCropBot - yCrop;

%%
allFrames = read(vid, [1 frameStop]);   % rows x cols x 3 x numFrames

croped = allFrames(yCrop:yCropBot, xCrop:xCropBot, :, :);

BW = ((croped(:,:,1,:) > Cmin(1)) & (croped(:,:,1,:) < Cmax(1))) & ...
     ((croped(:,:,2,:) > Cmin(2)) & (croped(:,:,2,:) < Cmax(2))) & ...
     ((croped(:,:,3,:) > Cmin(3)) & (croped(:,:,3,:) < Cmax(3)));

BW = reshape(BW, size(BW,1), size(BW,2), frameStop);

nRows = size(BW,1);
nCols = size(BW,2);

rowIdx = reshape(1:nRows, [nRows 1 1]);
colIdx = reshape(1:nCols, [1 nCols 1]);

mass = reshape(sum(sum(BW,1),2), [frameStop 1]);

cRow = reshape(sum(sum(double(BW).*rowIdx,1),2), [frameStop 1]) ./ mass;
cCol = reshape(sum(sum(double(BW).*colIdx,1),2), [frameStop 1]) ./ mass;

xPos = cCol;
yPos = cropH - cRow;

%% Compute one global ball scale from the whole video

validFrames = mass > 0;

% Equivalent diameter in pixels for each valid frame
ballDPxVec = sqrt(4 * mass(validFrames) / pi);

% One diameter for the entire video
ballDPx = median(ballDPxVec);

% One pixel-to-meter scale for the entire video
px2m = ballDm / ballDPx;

%% Threshold Video
for k = 1:frameStop
    subplot(1,2,1)
    imshow(BW(:,:,k))
    aspectRatio = pbaspect;

    subplot(1,2,2)
    plot(xPos(1:k), yPos(1:k), 'b-')
    hold on
    plot(xPos(k), yPos(k), 'rx')
    hold off
    pbaspect(aspectRatio)
    axis([0, cropW, 0, cropH])
    drawnow
end

%% Plot y position, velocity, and acceleration

% Vertical position in meters, positive upward
yPos = (cropH - cRow(frameStart:frameStop)) * px2m;
yPos = yPos - min(yPos);

% Time vector in seconds
t = (0:length(yPos)-1)/frameRate;

% Smooth position slightly before differentiating
yPosSmooth = smoothdata(yPos,5);



% Vertical velocity and acceleration
vy = gradient(yPosSmooth, t);
ay = gradient(vy, t);

figure

subplot(3,1,1)
plot(t, yPos, 'b-', t, yPosSmooth, 'r-', 'LineWidth', 1.2)
xlabel('Time (s)')
ylabel('y Position (m)')
legend('Raw y','Smoothed y')
title('Vertical Position vs Time')
grid on

subplot(3,1,2)
plot(t, vy, 'b-', 'LineWidth', 1.2)
xlabel('Time (s)')
ylabel('v_y (m/s)')
title('Vertical Velocity vs Time')
grid on

subplot(3,1,3)
plot(t, ay, 'b-', 'LineWidth', 1.2)
xlabel('Time (s)')
ylabel('a_y (m/s^2)')
title('Vertical Acceleration vs Time')
legend('Measured a_y','g = -9.81 m/s^2')
grid on

%% Calculate coefficient of restitution and make stem plot
%% Coefficient of restitution

% Bounce heights should be measured from y = 0 (ground level),
% which is already true since you used:
% yPos = yPos - min(yPos);

% Find rebound peaks in the smoothed vertical position
[minPeakDistFrames, ~] = deal(round(0.10 * frameRate), []);
[pks, locs] = findpeaks(yPosSmooth, ...
    'MinPeakDistance', minPeakDistFrames, ...
    'MinPeakProminence', 0.02 * max(yPosSmooth));

% Include the initial drop height as the first height
hVec = [yPosSmooth(1); pks(:)];

% Coefficient of restitution for each bounce:
% e_n = sqrt(h_(n+1) / h_n)
eVec = sqrt(hVec(2:end) ./ hVec(1:end-1));

% Bounce number vector
bounceNum = (1:length(eVec)).';

% Display values
disp('Bounce heights (m):')
disp(hVec)

disp('Coefficient of restitution for each bounce:')
disp(eVec)

disp('Mean coefficient of restitution:')
disp(mean(eVec, 'omitnan'))

% Stem plot of restitution coefficient
figure
stem(bounceNum, eVec, 'filled', 'LineWidth', 1.2)
xlabel('Bounce Number')
ylabel('Coefficient of Restitution, e')
title('Coefficient of Restitution by Bounce')
grid on




%% Plot energies as a function of time

gMag = abs(G);   % use positive gravitational magnitude

% Kinetic energy (vertical motion only)
KE = 0.5 * ballMass * vy.^2;

% Gravitational potential energy
PE = ballMass * gMag * yPosSmooth;

% Total mechanical energy
TE = KE + PE;

figure

plot(t, KE, 'b-', 'LineWidth', 1.2)
hold on
plot(t, PE, 'r-', 'LineWidth', 1.2)
plot(t, TE, 'k-', 'LineWidth', 1.5)
hold off

xlabel('Time (s)')
ylabel('Energy (J)')
title('Energy vs Time')
legend('Kinetic Energy', 'Potential Energy', 'Total Energy')
grid on


