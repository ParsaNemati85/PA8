function [centRow, centCol] = Centroid(img)
% Calculates the centroid of a binary image in terms of the row and col
% numbers.
%   Input:    img -- black and white (binary) image
%   Outputs:  centRow -- row number of centroid
%             centCol -- col number of centroid

[rowNum, colNum] = size(img);

if sum(sum(img)) == 0
    warning('Binary image is all zeros/black. Check input image.')
    centRow = 0;
    centCol = 0;
else
    % Calculate sums
    sumRow = sum(img,2)';   % sum at a given row of all col
    sumCol = sum(img);      % sum at a given col of all row
    
    % Find centroid using formula sum(m_i*x_i)/sum(m_i)
    centRow = (sumRow.*(1:rowNum))/sumRow;
    centCol = (sumCol.*(1:colNum))/sumCol;
end