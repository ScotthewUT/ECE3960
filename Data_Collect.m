%% Collect Data (Uncomment when needed)
r = MKR_MotorCarrier;
blockNumber = 25;
Label = 3;
r.servo(2,0)
pause(5)
r.servo(2,180)
pause(2)
data = data_gather(r)
%save(['block-',num2str(blockNumber),'.mat'],'data')
r.servo(2,0)
%% Read In data

saveDirectory = [pwd, '\data'];
temp = dir(saveDirectory); %get all files in save location
filenames = temp(3:end); %get files only
combinedData = []; %preallocate data
%load([filenames(1).folder,'\', filenames(1).name])
%combinedData = [data];
for fileIdx = 1:length(filenames)
    load([filenames(fileIdx).folder,'\', filenames(fileIdx).name]) %load data
    try
        combinedData = [combinedData; data]; %combine data 
    catch
        fprintf('Data from file %s is invalid. Dimensions are inconsistent!\n',filenames(fileIdx).name);
    end
end

%% Test
M = 1250;
dataset = zeros(5,1,1,M);
labels = zeros(1,M);

k=1; %simpler counter
for a = 1:M %iterate through gestures
    dataset(:,:,:,k) = combinedData(a, 1:5); %put each feature into image stack
    labels(k) = combinedData(a, 6); %put each label into label stack
    k = k + 1; %increment
end
%% Split Datasets
%dataset = combinedData(:,1:5);
%labels = combinedData(:,6);
labels = categorical(labels);

M = round(length(dataset));
indexes = linspace(1, M, M);
indexes = indexes(randperm(M));


xTest = dataset(:,:,1,indexes(1:round(M/4)));
yTest = labels(indexes(1:round(M/4)));

xTrain = dataset(:,:,1,indexes(round(M/4)+1:M));
yTrain = labels(indexes(round(M/4)+1:M));

%% 
numClasses = 3;

%%%%%%%%%%%%%%%%%%%%% YOU SHOULD MODIFY THESE PARAMETERS %%%%%%%%%%%%%%%%%%%

learnRate = 0.003; %how quickly network makes changes and learns
maxEpoch = 10000; %how long the network learns

%%%%%%%%%%%%%%%%%%%%%%% END OF YOUR MODIFICATIONS %%%%%%%%%%%%%%%%%%%%%%

layers= [ ... %NN architecture for a simple perceptron
    imageInputLayer([5,1,1])
    fullyConnectedLayer(numClasses)
    dropoutLayer(.4)
    softmaxLayer
    classificationLayer
    ];

options = trainingOptions('sgdm','InitialLearnRate', learnRate, 'MaxEpochs', maxEpoch,...
    'Shuffle','every-epoch','Plots','training-progress', 'ValidationData',{xTest,yTest}); %options for NN

%% Train Neural Network

myNeuralNetwork=trainNetwork(xTrain,yTrain,layers,options); %output is the trained NN

%% Test Neural Network

predictions = classify(myNeuralNetwork, xTest)'; %classify testing data using NN
disp("The Neural Network Predicted:"); disp(predictions); %display predictions
disp("Correct Answers"); disp(yTest); % display correct answers
figure(); confusionchart(yTest,predictions); % plot a confusion matrix

%% % make sure NN exists
if(~exist('myNeuralNetwork'))
    error("You have not yet created your neural network! Be sure you run this section AFTER your neural network is created.");
end

% collect gesture
Label = 1;
r = MKR_MotorCarrier;
rtdata = data_gather(r, Label)

% put accelerometer data into NN input form
xTest = zeros(5,1,1,1);

xTest(:,:,:,1) = rtdata; % YOU CAN MODIFY THIS LINE 

% Prediction based on NN
prediction = classify(myNeuralNetwork,xTest);

% Plot with label
figure(); plot(rtdata', 'LineWidth', 1.5); %plot accelerometer traces
legend('X','Y','Z'); ylabel('Acceleration'); xlabel('Time') %label axes
title("Classification:", string(prediction)); %title plot with the label


