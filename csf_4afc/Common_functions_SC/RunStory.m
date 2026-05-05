if ~Parameters.SkipInstructions
    Screen('DrawTexture', w, jungleIdx,[],ScreenRect);
    Screen('flip',w);
    WaitSecs(0.1);
    KbWait();
    WaitSecs(0.01);
    
    Screen('DrawTexture', w, ZebraIdx);
    Screen('flip',w);
    WaitSecs(0.1);
    KbWait();
    WaitSecs(0.01);
    
    Screen('DrawTexture', w, hiddenZebraIdx,[],ScreenRect);
    Screen('flip',w);
    WaitSecs(0.1);
    KbWait();
    WaitSecs(0.01);
end