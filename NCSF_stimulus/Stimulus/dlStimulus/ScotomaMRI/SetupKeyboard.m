function kb = SetupKeyboard()
% Setup universal Mac/PC keyboard and keynames

ListenChar(2); % Stop making keypresses show up in matlab

% Fix for multiple keyboards
% if IsOSX || IsMac
%     kb.ID = max(GetKeyboardIndices);
% else
%     kb.ID = -1;
% end

% Fix for 64/32-bit problem on Mac OS X
KbCheck;

kb.ID = -1;

KbName('UnifyKeyNames');

kb.escKey = KbName('ESCAPE');
kb.oneKey = KbName('1!');
kb.twoKey = KbName('2@');
kb.threeKey = KbName('3#');
kb.fourKey = KbName('4$');
kb.fiveKey = KbName('5%');
kb.sixKey = KbName('6^');
kb.sevenKey = KbName('7&');
kb.eightKey = KbName('8*');
kb.nineKey = KbName('9(');
kb.zeroKey = KbName('0)');
kb.qKey = KbName('q');
kb.wKey = KbName('w');
kb.eKey = KbName('e');
kb.rKey = KbName('r');
kb.spaceKey = KbName('space');
kb.pKey = KbName('p');
kb.oKey = KbName('o');
kb.iKey = KbName('i');
kb.jKey = KbName('j');
kb.kKey = KbName('k');
kb.lKey = KbName('l');
kb.zKey = KbName('z');
kb.xKey = KbName('x');
kb.cKey = KbName('c');
kb.aKey = KbName('a');
kb.sKey = KbName('s');
kb.dKey = KbName('d');
kb.fKey = KbName('f');
kb.nKey = KbName('n');

kb.upKey = KbName('UpArrow');
kb.downKey = KbName('DownArrow');

kb.quitKey = kb.qKey;

% Key mappings for Scotoma experiment
kb.movedLeft = kb.fKey;     % OR towards observer
kb.movedRight = kb.jKey;    % OR away from observer

kb.breakKey = kb.escKey;


% Initialize KbCheck
[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(kb.ID);
end