function [classification] = classify_block(data, myNeuralNetwork)
    % Put sensor data into proper arrays
    xTest = zeros(5,1,1,1);
    xTest(:,:,:,1) = data;
    classification = classify(myNeuralNetwork,xTest);
end