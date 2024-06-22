% Function to extract iris from the eye using statistical methods
function irisImage = extractIrisStatistical(inputImage)
    % Convert the image to grayscale
    grayImage = rgb2gray(inputImage);

    % Convert to double for calculations
    grayImage = double(grayImage);

    % Compute statistical properties of the image
    meanIntensity = mean(grayImage(:));
    stdIntensity = std(grayImage(:));

    % Threshold based on statistical properties
    threshold = meanIntensity + 0.5 * stdIntensity; % Adjust threshold as needed
    binaryImage = grayImage > threshold;

    % Fill holes in the binary image
    filledImage = imfill(binaryImage, 'holes');

    % Find connected components
    cc = bwconncomp(filledImage);

    % Filter out components based on area
    areas = cellfun(@numel, cc.PixelIdxList);
    [~, idx] = max(areas);
    irisMask = zeros(size(filledImage));
    irisMask(cc.PixelIdxList{idx}) = 1;

    % Apply the mask to the original image
    irisImage = inputImage .* uint8(repmat(irisMask, [1, 1, size(inputImage, 3)]));
end