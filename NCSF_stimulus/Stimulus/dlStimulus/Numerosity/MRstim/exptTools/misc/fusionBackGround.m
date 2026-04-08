function [backgroundTexture] = fusionBackGround(display, params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%For central fixation
[x,y] = meshgrid(-display.numPixels(1):display.numPixels(1),...
    -display.numPixels(1):display.numPixels(1));

%Centered on fixation point
% xFixDev=display.fixX-display.numPixels(1)/2;
% yFixDev=display.fixY-display.numPixels(2)/2;
%x=x+xFixDev;
%y=y+yFixDev;


% xFixDev=pix2angle(display, display.fixX-sSize.pix(2)/2);
% yFixDev=pix2angle(display, display.fixY-sSize.pix(1)/2);
% [x, y] = meshgrid(linspace(-sSize.deg(2)./2-xFixDev,sSize.deg(2)./2-xFixDev,sSize.pix(2)),...
%     linspace(-sSize.deg(1)./2-yFixDev,sSize.deg(1)./2-yFixDev,sSize.pix(1)));

noysSlope = 1.0; %1.5;
% pa.rmax_bg_p10 = angle2pix(display,params.radius+.5+.5); % radius beyond which NOT to show nonius lines
% pa.rmax_bg_p5 = angle2pix(display,params.radius); % radius beyond which to show nonius lines
% pa.rmax_bg = angle2pix(display,params.radius); % radius beyond which to show background
% pa.rmin_bg= angle2pix(display,.25); % degrees
% ds.white = 255;

pa.rmax_bg_p10 = angle2pix(display,3); % radius beyond which NOT to show nonius lines
pa.rmax_bg_p5 = angle2pix(display,0.25); % radius beyond which to show nonius lines
pa.rmax_bg = angle2pix(display,params.radius.*3); % radius beyond which to show background
pa.rmin_bg= angle2pix(display,3); % degrees
ds.white = 255;


% noys = ds.white .* oneoverf(noysSlope, size(display.numPixels,1), size(display.numPixels,2));
% noys = ds.white .* zeros(size(x,1), size(x,2)); % Temp fix for lack of Vistools
noys = ds.white .* oneoverf(noysSlope, size(x,1), size(x,2));

% Additional fixation nonius lines outside aperture  
noys(abs(x) < 2 & abs(y)>(pa.rmax_bg_p5) & abs(y)<(pa.rmax_bg_p10)) = 1 .* ds.white;
noys(abs(y) < 2 & abs(x)>(pa.rmax_bg_p5) & abs(x)<(pa.rmax_bg_p10)) = 0 .* ds.white;

% noys(abs(x-pa.rmax_bg)<2 & y == 0) = 0 .* ds.white;
% noys(abs(y-pa.rmax_bg)<2 & x == 0) = 1 .* ds.white;

% noys(abs(x-pa.rmax_bg)<2 & abs(y)>(pa.rmax_bg + angle2pix(.5))) = 0 .* ds.white;
% noys(abs(y-pa.rmax_bg)<2 & abs(x)>(pa.rmax_bg + angle2pix(.5))) = 1 .* ds.white;

% Add (alpha) transparency map
noys(:,:,2) = ds.white .* (sqrt(x.^2+y.^2) > pa.rmax_bg); % outer region
noys(:,:,2)= noys(:,:,2) + ds.white.*((x.^2+y.^2) < pa.rmin_bg.^2); % inner region

% draw nonius lines beyond rmax_bg
% If we we do that here, it cannot be eye dependent
% noniusSize = round(pa.rmax_bg:pa.rmax_bg+20);
% noys(,0,1) = 1 * ds.white;
% noys(0,round(pa.rmax_bg:pa.rmax_bg+20),1) = 0 * ds.white;

backgroundTexture = Screen('MakeTexture', display.windowPtr, round(noys));
end

