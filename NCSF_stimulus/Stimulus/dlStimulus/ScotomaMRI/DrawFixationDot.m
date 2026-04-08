function DrawFixationDot(ds,pa)
    
    Screen('SelectStereoDrawBuffer',ds.w,0);
    Screen('DrawDots',ds.w,[0 0],pa.fixationDotSize,pa.fixationDotColor,[ds.windowRect(3)./2 ds.windowRect(4)./2],2);
    
    Screen('SelectStereoDrawBuffer',ds.w,1);
    Screen('DrawDots',ds.w,[0 0],pa.fixationDotSize,pa.fixationDotColor,[ds.windowRect(3)./2 ds.windowRect(4)./2],2);

end