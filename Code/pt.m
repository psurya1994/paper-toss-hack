%% Code for paper toss hack
% By Surya Penmetsa

clear all
close all
clc


while 1
    system('adb shell screencap -p /sdcard/otdraw/pt.png');
    system('adb pull /sdcard/otdraw/pt.png');
    system('adb shell rm /sdcard/otdraw/pt.png');

    frame = imread('pt.png');
    frame = rgb2gray(frame);
    figure(1), imshow(frame);

    %% Finding wind value
    text = imcrop(frame, [485 1478 592-485 1523-1478]);
    textBinary = im2bw(text, 0.87);
    textBinary = bwareaopen(textBinary, 40);
    figure(2), imshow(textBinary)
    stats = regionprops(textBinary, 'Perimeter','Eccentricity');
    if(size(stats)<3)
        disp('Improper thresholding')
        quit
    end

    perimetersMain = [84.5, 68.5, 145.5, 145.5, 112.5, ...
                      167, 118.5, 131, 100, 93.5];

    similarity = zeros(10,3);
    for i = 1:3
        similarity(:,i) = abs(perimetersMain - stats(i).Perimeter);
    end

    ocr = zeros(1,3);
    for i = 1:3
        [val, ocr(i)] = min(similarity(:,i));
    end

    for i = 1:3
        if(ocr(i)==3 || ocr(i)==4)
            if(stats(i).Eccentricity>0.8)
                ocr(i) = 3;
            else
                ocr(i) = 4;
            end
        end
    end
    ocr = ocr - 1;
    wind = ocr(1) + ocr(2)/10 + ocr(3)/100;
    disp(['The windspeed is: ', num2str(wind)])

    %% Finding wind direction
    dir = imcrop(frame, [432 1530 471-432 1579-1530]);
    dirBinary = im2bw(dir,0.8);
    imshow(dirBinary)

    stats = regionprops(dirBinary, 'Area');
    if(stats.Area>400)
        direction = -1;
    else
        direction = 1;
    end
    disp(['The wind direction is: ' num2str(direction)])

    %% Finding direction of projection
    if(wind<2)
        theta = atan(-wind*direction/8);
    elseif(wind<4)
        theta = atan(-wind*direction/6);
    elseif(wind<5)
        theta = atan(-wind*direction/5.5);
    elseif(wind<5.5)
        theta = atan(-wind*direction/4.7); 
    elseif(wind<5.85)
        theta = atan(-wind*direction/4);   
    elseif(wind<6)
        theta = atan(-wind*direction/3.5);
    end

    disp(['The angle is: ', num2str(theta*180/pi)]);
    swipeLength = 400;
    xstart = 480;
    ystart = 1920 - 100;
    xend = xstart + swipeLength*sin(theta);
    yend = ystart - swipeLength*cos(theta);

    system(['adb shell input swipe ' num2str(xstart) ' ' num2str(ystart) ' ' ...
                                     num2str(xend) ' ' num2str(yend) ' ' '100']);

    pause (2);
end