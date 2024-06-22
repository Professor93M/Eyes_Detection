% Read the image
img = imread('img1.jpg');

% Convert the image to grayscale
gray_img = rgb2gray(img);

% Detect faces
faceDetector = vision.CascadeObjectDetector();
bbox = step(faceDetector, gray_img);

% If multiple faces are detected, you might want to choose the most prominent one
% For simplicity, let's assume only one face is detected
if ~isempty(bbox)
    % Extract the region of interest containing the face
    face = imcrop(gray_img, bbox(1,:));

    % Detect eyes within the face region
    eyeDetector = vision.CascadeObjectDetector('EyePairBig');
    bbox_eye = step(eyeDetector, face);

    % Extract the region containing the eyes
    if ~isempty(bbox_eye)
        % Assuming only one pair of eyes is detected
        eyes = imcrop(face, bbox_eye(1,:));

        % Convert the eyes to binary image using adaptive thresholding
        binary_eyes = imbinarize(eyes);

        % Apply morphological operations to remove noise and refine the binary image
        binary_eyes = bwareaopen(binary_eyes, 50); % Remove small objects
        binary_eyes = imfill(binary_eyes, 'holes'); % Fill holes
        se = strel('disk', 3); % Define structuring element for dilation
        binary_eyes = imdilate(binary_eyes, se); % Dilate the binary image

        % Find connected components in the binary image
        cc = bwconncomp(binary_eyes);
        num_iris = cc.NumObjects;

        % Display the eyes
        figure;
        subplot(2, num_iris, 1);
        imshow(eyes);
        title('Eyes');

        % Extract each iris separately
        for i = 1:num_iris
            iris_region = zeros(size(eyes));
            iris_region(cc.PixelIdxList{i}) = 255; % Set pixels corresponding to iris to white
            subplot(2, num_iris, num_iris + i);
            imshow(iris_region);
            title(['Iris ', num2str(i)]);
        end
    else
        disp('Eyes not detected.');
    end
else
    disp('Face not detected.');
end
