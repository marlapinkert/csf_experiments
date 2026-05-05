singleTrialCounter(1) = [];
% Save the workspace
save(SaveName);

% Plot the CSF (x-axis log scale, y-axis linear scale)
PlotStaircaseData();

% TIMESTAMP = strrep(strrep(datestr(now),' ',''),':','');
% SaveName = sprintf('%s_%2.0f_%s',subject_num,subject_DOB,TIMESTAMP);

%%
% %@todo implement
% mydat = struct();
% mydat.singleTrialCounter = singleTrialCounter;
% mydat.PresentedContrast = PresentedContrast;
% mydat.PresentedFreq = PresentedFreq;
% mydat.respDuration = respDuration;
% mydat.isCatch = isCatch;
% mydat.CorrectAns = CorrectAns;
% mydat.reversalValsFinal = reversalValsFinal;
% mydat.BlockNum = BlockNum;
% mydat.timeStamp = timeStamp;
% mydat.respondedLoc = respondedLoc;
% mydat.targetLoc = targetLoc;
% mydat.meanFixation = meanFixation;
% mydat.isETTracking = isETTracking;
% mydat.wasAborted = wasAborted;
% mydat.isRevesal = isRevesal;
% mydat.catchTrialNum = catchTrialNum;
% mydat.subject_DOB = Parameters.Subj_DOB;
% mydat.subject_num = Parameters.Subj_ID;
% 
% % CSVSaveName = sprintf('%s_%s_%s.csv',subject_num,num2str(subject_DOB),num2str(TIMESTAMP));
% struct2csv(mydat, CSVSaveName, true)
