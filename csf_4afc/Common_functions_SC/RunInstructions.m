if ~Parameters.SkipInstructions
    SceneImg = sprintf('%0.0f.jpg',LevelCountM);
    SceneImg = imread(SceneImg);
    SceneIdx=Screen('MakeTexture', w, SceneImg);
    Screen('DrawTexture', w, SceneIdx,[],ScreenRect);
    Screen('Flip',w);
    WaitSecs(0.1);
    KbWait();
    WaitSecs(0.1);
end