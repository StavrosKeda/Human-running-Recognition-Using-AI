
%kodikas me to AI mesa (pou trexei)
% Connect to the mobile device
clear m
m = mobiledev;
m.AccelerationSensorEnabled = 1;
m.Logging = 1;
load('net2f')
% Initialize data for rolling plot
data = zeros(200, 3);

% Initialize plot
figure(1)
% Create subplots for acceleration data
ax1 = subplot(2, 1, 1);
p1 = plot(ax1, data(:, 1));
hold(ax1, 'on');
p2 = plot(ax1, data(:, 2));
hold(ax1, 'on');
p3 = plot(ax1, data(:, 3));
hold(ax1, 'on');

grid on;
ax1.XTickLabel = {'-1.4', '-1.2', '-1.0', '-0.8', '-0.6', '-0.4', '-0.2'};
label_string = text(1, -0.4,'NOT runn');
label_string.Interpreter = 'none';
label_string.FontSize = 20;


% Create a subplot for the spectrogram-like representation
specAx = subplot(2, 1, 2); 
scale_accel = image(zeros(224, 224, 3));

% Pause for a moment to let the plot initialize
pause(1)
counter = 0;
k = 0 ;
i = 0;

while (k < 1) % Run
l = 1;
for l = 1 : 2




   
    % Get new acceleration data
    [a, ~] = accellog(m);

    if size(a, 1) >= 200
        data = a(end-199:end, :);
    else
        data(1:size(a, 1), :) = a;
    end

    % Redraw the acceleration plots
    p1.YData = data(:, 1);
    p2.YData = data(:, 2);
    p3.YData = data(:, 3);

    % Compute and display the spectrogram-like representation


  fb = cwtfilterbank('SignalLength', 200, 'SamplingFrequency', ...
              1e3, 'VoicesPerOctave', 12);

sig = data(:, 1);
[cfs, ~] = wt(fb, sig);
cfs_abs = abs(cfs);
accel_i = imresize(cfs_abs/8, [224 224]);

sig = data(:, 2);
[cfs, ~] = wt(fb, sig);
cfs_abs = abs(cfs);
accel_i(:,:, 2) = imresize(cfs_abs/8, [224 224]);

sig = data(:, 3);
[cfs, ~] = wt(fb, sig);
cfs_abs = abs(cfs);
accel_i(:, :, 3) = imresize(cfs_abs/8, [224 224]);

% Saturate pixels at 1
if ~(isempty(accel_i(accel_i>1)))
    accel_i(accel_i>1) = 1;

end

scale_accel.CData = im2uint8(accel_i);

%classify scalogram
[YPred, probs] = classify(trainedNetwork_1, scale_accel.CData);
%%%
stat=true;

if i == 1
if mod(counter, 2) == 0


  fprintf('%f \n',(counter)/2);
  pause(1)
end
 counter = counter + 1;
end

%%%

    if l == 1 
        

if strcmp(string(YPred), 'run')
    grid on;
 i = 1;
label_string.BackgroundColor = [1 0 0];
label_string.String = "runn";

else

    i = 0;
    label_string.BackgroundColor = [1 1 1];
    grid on;
    label_string.String = "IS NOT RUN";
 end
    
    end



   
    drawnow
end
end
 
% Disconnect from the mobile device
m.Logging = 0;
disconnect(m);
