function Test10Bits

	 p.screenNumber = max(Screen('Screens'));
	 AssertOpenGL;
	 Screen('Preference', 'SkipSyncTests', 1);

	 masterGammaTable = ones(256, 3);

	 windowPtr = Screen('OpenWindow', p.screenNumber, 255, [], 32, 2);
	 Screen('LoadNormalizedGammaTable', windowPtr, masterGammaTable);

	 Screen('FillRect', windowPtr, 0);
	 Screen('Flip', windowPtr);

	 while 1==1
		 volts = input('Normalized Voltage Value (0-1): ');
		 thisGammaTable = volts * masterGammaTable;
		 Screen('LoadNormalizedGammaTable', windowPtr, thisGammaTable);
	 end

	 Screen('CloseAll');

end

