function [ avgVector ] = sumEachN( inputVector, N )
% sumEachN takes the sum over each N elements of input vector.
% throws error if length of inputVector doesn't divide by N:
if mod(length(inputVector), N) ~= 0
    error('Input vector length not divisible by N');
end

% the averaged vector
avgVector = arrayfun(@(i) sum(inputVector(i:i+N-1)),...
    1:N:length(inputVector)-N+1)';

end
