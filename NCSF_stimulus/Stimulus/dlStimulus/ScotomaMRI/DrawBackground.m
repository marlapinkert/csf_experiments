function DrawBackground(ds)

Screen('SelectStereoDrawBuffer', ds.w, 1);
Screen('DrawTexture', ds.w, ds.bg(ds.curBg));
Screen('DrawLines', ds.w, ds.fixationCrosshairs(:,1:4), ds.lineWidth, ds.fixationCrosshairColors(:,1:4), ds.windowCenter, 1);

Screen('SelectStereoDrawBuffer', ds.w, 0);
Screen('DrawTexture', ds.w, ds.bg(ds.curBg));
Screen('DrawLines', ds.w, ds.fixationCrosshairs(:,5:8), ds.lineWidth, ds.fixationCrosshairColors(:,1:4), ds.windowCenter, 1);