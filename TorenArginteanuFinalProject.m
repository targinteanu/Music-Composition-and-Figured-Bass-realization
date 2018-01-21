function finalproj

%% setting up the window and background
width = 1280; windowheight = 550; margin = 200;
rng('shuffle')

data = load('TorenArginteanuFinalProjectData');
Fclef = data.Fclef; Gclef = data.Gclef; fs = data.fs; 
notesound = data.notesound;

% create the GUI but make it invisible for now
window = figure('Visible','off','Position',[360,500,width,windowheight]);

% create a grand staff image matrix that forms the background for notes:
middlespace = 5;
space = 7; staffheight = (8+middlespace+2)*space;
grandstaff = ones(staffheight, width-2*margin);
for i = space*(1:5)
    % draw 5 black treble cleff lines
    grandstaff(i,:) = 0;
    % draw 5 black bass cleff lines 
    grandstaff(staffheight-i,:) = 0;
end
grandstaff(space:(end-space),1) = 0; grandstaff(space:(end-space),end) = 0; 

% add clefs 
grandstaff = impose(grandstaff, Gclef, 2, 2);
grandstaff = impose(grandstaff, Fclef, staffheight-35, 2);

% add axes and grand staff to window
grandstaff = [grandstaff; ones(uint8(staffheight/3), width-2*margin)];
grandstaff = [ones(uint8(staffheight/3), width-2*margin); grandstaff];
%staffheight = uint8(1.5*staffheight);
axheight = 290;
ax = axes('Units','Pixels','Position', [margin, axheight, width-2*margin, 2.5*staffheight]);
imshow(grandstaff);

%% notes that can be moved
% note colors indicate whether they are selected:
inact = .6*[1, 1, 1]; act = [0 0 0]; sel = [0 0 1]; acc = [1 0 1]; 
% a gray note is not active; the user must select it to make the program
% actually consider it. A black note is considered by the program. A blue
% note is selected, meaning it can be moved up and down in the major scale.
% A purple note is moved chromatically, adding/removing accidentals. 
errorcolor = [1 0 0]; % if a note is red, something is wrong. 

% drawing the oval shape
R = space; r = space-4; a = .2;
ovalx = linspace(-R, R); 
R = R^2; r = r^2;
ovaly = (sqrt(R*r*((cos(a)^2)*R-(ovalx.^2)+r*(sin(a)^2)))-sin(a)*cos(a)*(R-r)*ovalx)/(R*(cos(a)^2)+r*(sin(a)^2));
ovaly = real(ovaly);
ovalx = [ovalx, fliplr(ovalx)]; ovaly = [ovaly, (-ovaly)];
% bass, tenor, alto, soprano start at a, g, f, e, respectively
bassline = (4/3)*staffheight-1.5*space;
tenorline = bassline - 3*space;
altoline = tenorline-(middlespace+1)*space;
sopranoline = altoline - 3*space;
% ovalx and ovaly are converted to matrices whose columns hold the x- and
% y-coordinates for drawing individual ovals. 
nbass = 11; %sets the max amount of notes that can be "added"
            %("adding" a note just means making it visible)
notexs = (linspace(margin/2, width-2.5*margin, nbass));
ovalx = notexs+ovalx';
ovaly = repmat(ovaly, [nbass 1])';
stemheight = 4*space;
notexs = notexs-sqrt(R);

% initialize the notes of the four voices (bass, tenor, alto, soprano) as
% struct arrays containing all properties, including patches for visual
% representation, a text box for accidentals, and a menu for the user to
% modify 
for i = 1:nbass
    % initialize bass (the only voice with figures)
    
    % noteshape and stem are shapes that visually represent the notes:
    noteshape = patch(ovalx(:,i), bassline+ovaly(:,i), inact);
    noteshape.EdgeColor = noteshape.FaceColor;
    stem = patch((notexs(i))*[1 1], [bassline, bassline+stemheight], inact);
    stem.EdgeColor = noteshape.EdgeColor;
    
    % btn is a menu that allows the user to modify the note:
    btn = uicontrol('Style','popupmenu','Units','Pixels', ...
        'Position',[margin+notexs(i) + 3*sqrt(R), axheight+2*staffheight-bassline, 2*sqrt(R)+2, space+2],...
        'Callback',@notemenu, 'UserData',['bass(', num2str(i), ')'], ...
        'String', {'add', 'remove', 'move', char([9839,9838,9837]), 'done'});
    
    % bass only: figboxes are input boxes for the user to input figures.
    figbox1 = uicontrol('Style', 'edit', 'Units', 'Pixels', ...
        'Position',[margin+notexs(i)-2, axheight+staffheight/3, 3*sqrt(R), space*2],...
        'String', '', 'Callback', @figboxselected);
    figbox2 = uicontrol('Style', 'edit', 'Units', 'Pixels', ...
        'Position',[margin+notexs(i)-2, axheight+staffheight/3-2*space, 3*sqrt(R), space*2],...
        'String', '');
    figbox3 = uicontrol('Style', 'edit', 'Units', 'Pixels', ...
        'Position',[margin+notexs(i)-2, axheight+staffheight/3-4*space, 3*sqrt(R), space*2],...
        'String', '');

    txt = annotation('textbox'); txt.EdgeColor = 'none'; 
    txt.String = ' ';
    txt.Units = 'Pixels';
    txt.Position = [margin+notexs(i) - 3*sqrt(R), axheight+2*staffheight-bassline+space, 2*sqrt(R)+2, 2*sqrt(R)+2];
    
    bass(i) = struct('notehead', noteshape, 'stem', stem, ...
        'letter', 'a ', 'num', 3, ...
        'button', btn, 'accidental', txt, ...
        'figure', [' 1'; ' 3'; ' 5'], 'fig1', figbox1, 'fig2', figbox2, 'fig3', figbox3);
    % bass notes are initialized to the note a3 by default: letter a, num 3
    
    % initialize the tenor:
    noteshape = patch(ovalx(:,i), tenorline+ovaly(:,i), inact);
    noteshape.EdgeColor = noteshape.FaceColor;
    stem = patch((notexs(i))*[1 1]+2*sqrt(R), [tenorline, tenorline-stemheight], inact);
    stem.EdgeColor = noteshape.EdgeColor;
    
    btn = uicontrol('Style','popupmenu','Units','Pixels', ...
        'Position',[margin+notexs(i) + 3*sqrt(R), axheight+2*staffheight-tenorline+space, 2*sqrt(R)+2, space+2],...
        'Callback',@notemenu, 'UserData',['tenor(', num2str(i), ')'], ...
        'String', {'add', 'remove', 'move', char([9839,9838,9837]), 'done'});
    
    txt = annotation('textbox'); txt.EdgeColor = 'none'; 
    txt.String = ' ';
    txt.Units = 'Pixels';
    txt.Position = [margin+notexs(i) - 3*sqrt(R), axheight+2*staffheight-tenorline+space, 2*sqrt(R)+2, 2*sqrt(R)+2];
    
    tenor(i) = struct('notehead', noteshape, 'stem', stem, ...
        'letter', 'g ', 'num', 4, ...
        'button', btn, 'accidental', txt);
    % tenor notes are initialized at g4
    
    % initialize the alto:
    noteshape = patch(ovalx(:,i), altoline+ovaly(:,i), inact);
    noteshape.EdgeColor = noteshape.FaceColor;
    stem = patch((notexs(i))*[1 1], [altoline, altoline+stemheight], inact);
    stem.EdgeColor = noteshape.EdgeColor;
    
    btn = uicontrol('Style','popupmenu','Units','Pixels', ...
        'Position',[margin+notexs(i) + 3*sqrt(R), axheight+2*staffheight-altoline, 2*sqrt(R)+2, space+2],...
        'Callback',@notemenu, 'UserData',['alto(', num2str(i), ')'], ...
        'String', {'add', 'remove', 'move', char([9839,9838,9837]), 'done'});
    
    txt = annotation('textbox'); txt.EdgeColor = 'none'; 
    txt.String = ' ';
    txt.Units = 'Pixels';
    txt.Position = [margin+notexs(i) - 3*sqrt(R), axheight+2*staffheight-altoline+space, 2*sqrt(R)+2, 2*sqrt(R)+2];
    
    alto(i) = struct('notehead', noteshape, 'stem', stem, ...
        'letter', 'f ', 'num', 5, ...
        'button', btn, 'accidental', txt);
    % alto notes are initialized at f5
    
    % initialize the soprano:
    noteshape = patch(ovalx(:,i), sopranoline+ovaly(:,i), inact);
    noteshape.EdgeColor = noteshape.FaceColor;
    stem = patch((notexs(i))*[1 1]+2*sqrt(R), [sopranoline, sopranoline-stemheight], inact);
    stem.EdgeColor = noteshape.EdgeColor;
    
    btn = uicontrol('Style','popupmenu','Units','Pixels', ...
        'Position',[margin+notexs(i) + 3*sqrt(R), axheight+2*staffheight-sopranoline+space, 2*sqrt(R)+2, space+2],...
        'Callback',@notemenu, 'UserData',['soprano(', num2str(i), ')'], ...
        'String', {'add', 'remove', 'move', char([9839,9838,9837]), 'done'});
    
    txt = annotation('textbox'); txt.EdgeColor = 'none'; 
    txt.String = ' ';
    txt.Units = 'Pixels';
    txt.Position = [margin+notexs(i) - 3*sqrt(R), axheight+2*staffheight-sopranoline+space, 2*sqrt(R)+2, 2*sqrt(R)+2];
    
    soprano(i) = struct('notehead', noteshape, 'stem', stem, ...
        'letter', 'e ', 'num', 6, ...
        'button', btn, 'accidental', txt);
    % soprano notes are initialized at e6
end
    
% set up the first bass note as the only "active" (black) note and the
% notes immediately surrounding it (first tenor/alto/soprano and second
% bass) as grayed out; set all other notes as invisible and turn them
% visible when they are able to be set by the user. 
% A note can be set by the user when its bass note has already been set, or
% if it is the next bass note. 
%bass(1).Color = act; 
bass(1).stem.EdgeColor = act; 
bass(1).notehead.EdgeColor = act; bass(1).notehead.FaceColor = act;
for ii = 3:nbass
    bass(ii).stem.Visible = 'off'; 
    bass(ii).notehead.Visible = 'off';
    bass(ii).button.Visible = 'off';
end
for ii = 2:nbass
    bass(ii).fig1.Visible = 'off';
    bass(ii).fig2.Visible = 'off';
    bass(ii).fig3.Visible = 'off';
    tenor(ii).stem.Visible = 'off';
    tenor(ii).notehead.Visible = 'off';
    tenor(ii).button.Visible = 'off';
    alto(ii).stem.Visible = 'off';
    alto(ii).notehead.Visible = 'off';
    alto(ii).button.Visible = 'off';
    soprano(ii).stem.Visible = 'off';
    soprano(ii).notehead.Visible = 'off';
    soprano(ii).button.Visible = 'off';
end

% buttons and other UI elements
upbutton = uicontrol('Style', 'pushbutton', 'String', 'up', 'Units', 'normalized', ...
    'Position', [.2 .4 .1 .1], 'Callback', @moveup);
downbutton = uicontrol('Style', 'pushbutton', 'String', 'down', 'Units', 'normalized', ...
    'Position', [.2 .2 .1 .1], 'Callback', @movedown);
startbutton = uicontrol('Style', 'pushbutton', 'String', 'start', 'Units', 'normalized', ...
    'Position', [.7 .4 .1 .1], 'Callback', @startcomp);
resetbutton = uicontrol('Style', 'pushbutton', 'String', 'reset', 'Units', 'normalized', ...
    'Position', [.7 .2 .1 .1], 'Callback', @reset);
playbackbutton = uicontrol('Style', 'pushbutton', 'String', 'play my composition', ...
    'Units', 'normalized', 'Position', [.4 .4 .2 .1], 'Callback', @playback);
examplebutton = uicontrol('Style', 'pushbutton', 'String', 'see an example', ...
    'Units', 'normalized', 'Position', [.4 .2 .2 .1], 'Callback', @samplecomp);
title = uicontrol('Style','text','Units','normalized','Position',[.3 .92 .4 .06], ...
    'String', 'Welcome to the figured bass music composer. Use the dropdown menus to select some notes.');
leapslider = uicontrol('Style', 'slider', 'Units', 'normalized', ...
    'Min', 9, 'Max', 18, 'Value', 10, 'Position', [.4 .08 .2 .05]);
slidertxt = uicontrol('Style', 'text', 'Units', 'normalized', ...
    'Position', leapslider.Position+[0 .05 0 0], 'String', 'Maximum Leapiness:');
helpbox = annotation('textbox');
helpbox.Position = [0 .5 .2 .2]; 
helpbox.String = 'You can put figures (such as "6", "#3", "b5", or "n2") in the boxes, starting with the top box, to determine what kind of chord will be used. Otherwise, a default chord will be used.'; 

%% display the window
% Move the GUI to the center of the screen.
   movegui(window,'center')
   % Make the GUI visible.
   window.Visible='on';
   
%% callback functions:

    function figboxselected(source, event)
        helpbox.Visible = 'off';
    end

    function playback(source, event)
        % creates a sound vector and plays it using the pre-recorded piano
        % notes in notesounds 
        
        allsound = [0];
        
        for j = 1:nbass
           if sum(bass(j).stem.EdgeColor == inact) < 3
              % the chord at j is "active" and should be included in the 
              % playback 
              index = dist('a ', 2, bass(j).letter, bass(j).num);
              currentsound = notesound{index};
              index = dist('a ', 2, tenor(j).letter, tenor(j).num);
              currentsound = currentsound + notesound{index};
              index = dist('a ', 2, alto(j).letter, alto(j).num);
              currentsound = currentsound + notesound{index};
              index = dist('a ', 2, soprano(j).letter, soprano(j).num);
              currentsound = currentsound + notesound{index};
              allsound = [allsound, currentsound];
           end
        end
        
        sound(allsound, fs);
        
    end

    function samplecomp(source, event)
        % creates a sample composition with chords C, d, G, C, a, D, G, C
        title.String = 'Here is an example. You can move the notes around, or press start to compose.'
        reset(source, event);
        for j = 1:9
            bass(j).button.Value = 1; notemenu(bass(j).button, event);
        end
        % set note values and move them up/down
        for j = [1, 4, 9]
            % these notes should be c4
            bass(j).letter = 'c '; bass(j).num = 4;
            increment(bass(j)); increment(bass(j));
        end
        for j = [7, 8]
            % these notes should be g3:
            bass(j).letter = 'g '; 
            decrement(bass(j));
        end
        bass(2).letter = 'd '; bass(2).num = 4; 
        increment(bass(2)); increment(bass(2)); increment(bass(2)); 
        bass(3).letter = 'b '; 
        increment(bass(3));
        % set the figures, where appropriate
        bass(3).fig1.String = '6';
        bass(6).fig1.String = '#6';
        bass(6).fig2.String = '4';
        bass(7).fig1.String = '6';
        bass(7).fig2.String = '4';
        bass(8).fig1.String = '7';
    end

    function reset(source, event)
        % return all elements to their starting state
        
        bass(1).stem.EdgeColor = act;
        bass(1).notehead.EdgeColor = act; bass(1).notehead.FaceColor = act;
        bass(1).notehead.Vertices = [ovalx(:,1), bassline+ovaly(:,1)];
        bass(1).stem.Vertices = [(notexs(1)),(notexs(1)); bassline, bassline+stemheight]';
        bass(1).button.Position = [margin+notexs(1) + 3*sqrt(R), axheight+2*staffheight-bassline, 2*sqrt(R)+2, space+2];
        bass(1).accidental.Position = [margin+notexs(1) - 3*sqrt(R), axheight+2*staffheight-bassline+space, 2*sqrt(R)+2, 2*sqrt(R)+2];
        
        for j = 3:nbass
            bass(j).stem.Visible = 'off';
            bass(j).notehead.Visible = 'off';
            bass(j).button.Visible = 'off';
        end
        for j = 2:nbass
            
            bass(j).fig1.String = ''; bass(j).fig2.String = ''; bass(j).fig3.String = '';
            bass(j).figure = ['  '; '  '; '  '];
            bass(j).notehead.Vertices = [ovalx(:,j), bassline+ovaly(:,j)];
            bass(j).stem.Vertices = [(notexs(j)),(notexs(j)); bassline, bassline+stemheight]';
            bass(j).button.Position = [margin+notexs(j) + 3*sqrt(R), axheight+2*staffheight-bassline, 2*sqrt(R)+2, space+2];
            bass(j).accidental.Position = [margin+notexs(j) - 3*sqrt(R), axheight+2*staffheight-bassline+space, 2*sqrt(R)+2, 2*sqrt(R)+2];
            bass(j).fig1.Visible = 'off';
            bass(j).fig2.Visible = 'off';
            bass(j).fig3.Visible = 'off';
            bass(j).notehead.FaceColor = inact; bass(j).notehead.EdgeColor = inact;
            bass(j).stem.EdgeColor = inact;
            bass(j).letter = 'a '; bass(j).num = 3;
            
            tenor(j).notehead.Vertices = [ovalx(:,j), tenorline+ovaly(:,j)];
            tenor(j).stem.Vertices = [(notexs(j))+2*sqrt(R),(notexs(j))+2*sqrt(R); tenorline, tenorline-stemheight]';
            tenor(j).button.Position = [margin+notexs(j) + 3*sqrt(R), axheight+2*staffheight-tenorline+space, 2*sqrt(R)+2, space+2];
            tenor(j).accidental.Position = [margin+notexs(j) - 3*sqrt(R), axheight+2*staffheight-tenorline+space, 2*sqrt(R)+2, 2*sqrt(R)+2];
            tenor(j).notehead.FaceColor = inact; tenor(j).notehead.EdgeColor = inact;
            tenor(j).stem.EdgeColor = inact;
            tenor(j).letter = 'g '; tenor(j).num = 4;
            tenor(j).stem.Visible = 'off';
            tenor(j).notehead.Visible = 'off';
            tenor(j).button.Visible = 'off';
            
            alto(j).notehead.Vertices = [ovalx(:,j), altoline+ovaly(:,j)];
            alto(j).stem.Vertices = [(notexs(j)),(notexs(j)); altoline, altoline+stemheight]';
            alto(j).button.Position = [margin+notexs(j) + 3*sqrt(R), axheight+2*staffheight-altoline, 2*sqrt(R)+2, space+2];
            alto(j).accidental.Position = [margin+notexs(j) - 3*sqrt(R), axheight+2*staffheight-altoline+space, 2*sqrt(R)+2, 2*sqrt(R)+2];
            alto(j).notehead.FaceColor = inact; alto(j).notehead.EdgeColor = inact;
            alto(j).stem.EdgeColor = inact;
            alto(j).letter = 'f '; alto(j).num = 5;
            alto(j).stem.Visible = 'off';
            alto(j).notehead.Visible = 'off';
            alto(j).button.Visible = 'off';
            
            soprano(j).notehead.Vertices = [ovalx(:,j), sopranoline+ovaly(:,j)];
            soprano(j).stem.Vertices = [(notexs(j))+2*sqrt(R),(notexs(j))+2*sqrt(R); sopranoline, sopranoline-stemheight]';
            soprano(j).button.Position = [margin+notexs(j) + 3*sqrt(R), axheight+2*staffheight-sopranoline+space, 2*sqrt(R)+2, space+2];
            soprano(j).accidental.Position = [margin+notexs(j) - 3*sqrt(R), axheight+2*staffheight-sopranoline+space, 2*sqrt(R)+2, 2*sqrt(R)+2];
            soprano(j).notehead.FaceColor = inact; soprano(j).notehead.EdgeColor = inact;
            soprano(j).stem.EdgeColor = inact;
            soprano(j).letter = 'e '; soprano(j).num = 6;
            soprano(j).stem.Visible = 'off';
            soprano(j).notehead.Visible = 'off';
            soprano(j).button.Visible = 'off';
        end
    end

    function startcomp(source, event)
        % compose music when the start button is pressed. 
        
        if sum(bass(2).stem.EdgeColor == inact) == 3
            title.String = 'Please provide more than one bass note.';
        else
        
        % if any notes were marked as errors, return them to their previous
        % color (which is still the color of the stem)
        for index = 1:nbass
            bass(index).notehead.FaceColor = bass(index).stem.EdgeColor;
            bass(index).notehead.EdgeColor = bass(index).stem.EdgeColor;
            tenor(index).notehead.FaceColor = tenor(index).stem.EdgeColor;
            tenor(index).notehead.EdgeColor = tenor(index).stem.EdgeColor;
            alto(index).notehead.FaceColor = alto(index).stem.EdgeColor;
            alto(index).notehead.EdgeColor = alto(index).stem.EdgeColor;
            soprano(index).notehead.FaceColor = soprano(index).stem.EdgeColor;
            soprano(index).notehead.EdgeColor = soprano(index).stem.EdgeColor;
        end
        
        % determine if the user inputs have parallels and notify the
        % user. 
        if checkuserparallels()
            title.String = 'Error: you have input parallel 5ths and/or octaves';
        else
            title.String = 'Here is your composition. Press start for a different one.';
        
            updatefigures();
            notdone = true; % we will be not done composing until certain
                            % conditions are satisfied, such as no parallel
                            % 5ths/8ths and not too much leap
            while notdone
                hasparallels = true;
                write(1);
                for index = 2:nbass
                    if sum(bass(index).stem.EdgeColor == inact) < 3
                        attempts = 0;
                            % if the program keeps attempting to compose
                            % but keeps running into parallels, it should
                            % start over from the first note. 
                            %debugger.String = 'checkpoint2';
                        while hasparallels & (attempts < 50)
                            write(index);
                            hasparallels = isparallel(bass(index-1),bass(index),tenor(index-1),tenor(index))|...
                                isparallel(bass(index-1),bass(index),alto(index-1),alto(index))|...
                                isparallel(bass(index-1),bass(index),soprano(index-1),soprano(index))|...
                                isparallel(tenor(index-1),tenor(index),alto(index-1),alto(index))|...
                                isparallel(tenor(index-1),tenor(index),soprano(index-1),soprano(index))|...
                                isparallel(alto(index-1),alto(index),soprano(index-1),soprano(index));
                            attempts = attempts + 1;
                            debugger.String = attempts;
                        end
                        notdone = hasparallels;
                        hasparallels = true;
                    end
                    if notdone
                        break;
                    end
                end
                                
                notdone = notdone | (leap() > leapslider.Value);
                % if either the leap is too large or the loop was broken
                % due to too many failed attempts while there are still
                % parallels, start over from the first note. 
            end
        end
        end
    end
        
    function notemenu(source, event)
        % callback function for the popup menu for each note. Enables the
        % user to add/remove notes, and select/deselect to move or add
        % accidentals. 
        color = inact;
        cmd = source.Value; %command input
        % possible commands: {'add', 'remove', 'move', '#/b', 'done'}
        % use the UserData of the button to access properties of the note
        note = eval(source.UserData);
        % use the UserData to get the index number of the note, a 1- or
        % 2-digit number 
        index = str2num(source.UserData(end-2:end-1));
        if isempty(index)
            index = str2num(source.UserData(end-1));
        end
        if cmd==1 | cmd==5
            color = act;                       
            
            % allow the user to add nearby notes, but do not change their
            % color
            bass(index).fig1.Visible = 'on';
            bass(index).fig2.Visible = 'on';
            bass(index).fig3.Visible = 'on';
            bass(index+1).button.Visible = 'on';
            bass(index+1).notehead.Visible = 'on';
            bass(index+1).stem.Visible = 'on';
            bass(index+1).fig1.Visible = 'on';
            bass(index+1).fig2.Visible = 'on';
            bass(index+1).fig3.Visible = 'on';
            tenor(index).stem.Visible = 'on';
            tenor(index).notehead.Visible = 'on';
            tenor(index).button.Visible = 'on';
            alto(index).stem.Visible = 'on';
            alto(index).notehead.Visible = 'on';
            alto(index).button.Visible = 'on';
            soprano(index).stem.Visible = 'on';
            soprano(index).notehead.Visible = 'on';
            soprano(index).button.Visible = 'on'; 
        end
        if cmd==2
            color = inact;
        end
        if cmd==3
            color = sel;
        end
        if cmd==4
            color = acc;
        end
        
        note.notehead.FaceColor = color;
        note.notehead.EdgeColor = color; 
        note.stem.EdgeColor = color;
        %debugger.String = note.notehead.FaceColor;
    end

    function moveup(source, event)
        for j = 1:nbass
            if bass(j).num < 5
                if sum(bass(j).stem.EdgeColor == sel) == 3 %note is blue/selected
                    [bass(j).num, bass(j).letter] = increment(bass(j));
                end
                if sum(bass(j).stem.EdgeColor == acc) == 3 %note is purple/selected for accidentals
                    [bass(j).num, bass(j).letter] = chrincrement(bass(j));
                end
            end
            if tenor(j).num < 6
                if sum(tenor(j).stem.EdgeColor == sel) == 3 %note is blue/selected
                    [tenor(j).num, tenor(j).letter] = increment(tenor(j));
                end
                if sum(tenor(j).stem.EdgeColor == acc) == 3 %note is purple/selected for accidentals
                    [tenor(j).num, tenor(j).letter] = chrincrement(tenor(j));
                end
            end
            if alto(j).num < 6
               if sum(alto(j).stem.EdgeColor == sel) == 3 %note is blue/selected
                    [alto(j).num, alto(j).letter] = increment(alto(j));
                end
                if sum(alto(j).stem.EdgeColor == acc) == 3 %note is purple/selected for accidentals
                    [alto(j).num, alto(j).letter] = chrincrement(alto(j));
                end 
            end
            if soprano(j).num < 7
               if sum(soprano(j).stem.EdgeColor == sel) == 3 %note is blue/selected
                    [soprano(j).num, soprano(j).letter] = increment(soprano(j));
                end
                if sum(soprano(j).stem.EdgeColor == acc) == 3 %note is purple/selected for accidentals
                    [soprano(j).num, soprano(j).letter] = chrincrement(soprano(j));
                end 
            end
        end
        debugger.String = [bass(1).letter num2str(bass(1).num)];
    end

    function movedown(source, event)
        for j = 1:nbass
            if bass(j).num > 2
                if sum(bass(j).stem.EdgeColor == sel) == 3 %note is blue/selected
                    [bass(j).num, bass(j).letter] = decrement(bass(j));
                end
                if sum(bass(j).stem.EdgeColor == acc) == 3 %note is purple/selected for accidentals
                    [bass(j).num, bass(j).letter] = chrdecrement(bass(j));
                end
            end
            if tenor(j).num > 3
                if sum(tenor(j).stem.EdgeColor == sel) == 3 %note is blue/selected
                    [tenor(j).num, tenor(j).letter] = decrement(tenor(j));
                end
                if sum(tenor(j).stem.EdgeColor == acc) == 3 %note is purple/selected for accidentals
                    [tenor(j).num, tenor(j).letter] = chrdecrement(tenor(j));
                end
            end
            if alto(j).num > 3
               if sum(alto(j).stem.EdgeColor == sel) == 3 %note is blue/selected
                    [alto(j).num, alto(j).letter] = decrement(alto(j));
                end
                if sum(alto(j).stem.EdgeColor == acc) == 3 %note is purple/selected for accidentals
                    [alto(j).num, alto(j).letter] = chrdecrement(alto(j));
                end 
            end
            if soprano(j).num > 4
               if sum(soprano(j).stem.EdgeColor == sel) == 3 %note is blue/selected
                    [soprano(j).num, soprano(j).letter] = decrement(soprano(j));
                end
                if sum(soprano(j).stem.EdgeColor == acc) == 3 %note is purple/selected for accidentals
                    [soprano(j).num, soprano(j).letter] = chrdecrement(soprano(j));
                end 
            end
        end
    end

%% note-moving functions and data
chromaticscale = ['a '; 'a#'; 'b '; 'c '; 'c#'; 'd '; 'd#'; 'e '; 'f '; 'f#'; 'g '; 'g#'];
orderedscale = ['c '; 'c#'; 'd '; 'd#'; 'e '; 'f '; 'f#'; 'g '; 'g#'; 'a '; 'a#'; 'b '];
majorscale = ['a '; 'b '; 'c '; 'd '; 'e '; 'f '; 'g '];
updatedscale = majorscale;

    function newnotestr = chromadd(notestr, halfsteps)
        %given a note string, returns the note string a certain amount of
        %halfsteps above (positive) or below (negative)
        indeces = chromaticscale == notestr;
        index = find(indeces(:,1).*indeces(:,2));
        % 'a ' will match only 'a ', and 'a#' will match only 'a#'.
        index = index-1;
        amount = mod(index + halfsteps, 12); 
        amount = amount+1;
        newnotestr = chromaticscale(amount,:);
    end

    function newnotestr = majadd(notestr, steps)
        %given a note string, returns the note string a certain amount of
        %steps above (positive) or below (negative) in the major scale
        indeces = majorscale == notestr;
        index = find(indeces(:,1));
        index = index-1;
        amount = mod(index + steps, 7);
        amount = amount+1;
        newnotestr = updatedscale(amount,:);
    end

accidentals = [char([9837; 9838; 9839]); ' '];

    function [newnum, newletter] = chrincrement(note)
        % takes a note struct and moves it up in the chromatic scale,
        % changing the identity of the note as well as adding an
        % accidental.
        
        % change the identity of the note:
        newletter = chromadd(note.letter, 1);
        if strcmp(newletter, 'c ')
            newnum = note.num+1;
        else
            newnum = note.num;
        end
        % (the letter and num of the note that this note is
        % being raised to.)
        
        % change the appearence of the note:
        % position of the note should change if the original accidental is
        % #. 
        if note.accidental.String == accidentals(3)
            note.notehead.Vertices(:,2) = note.notehead.Vertices(:,2)-space/2;
            note.stem.Vertices(:,2) = note.stem.Vertices(:,2)-space/2;
            note.button.Position(2) = note.button.Position(2)+space/2;
            note.accidental.Position(2) = note.accidental.Position(2)+space/2;
        end
        % add an accidental if newletter is not in the key sig. 
        indeces = newletter == updatedscale;
        if ~sum(indeces(:,1).*indeces(:,2))
            % the newletter is NOT in the key sig. If it is white, add a
            % natural; if it is black, add a sharp
            if newletter(2) == '#'
                % newletter is black; add a sharp
                note.accidental.String = accidentals(3);
            else
                % newletter is white; add a natural
                note.accidental.String = accidentals(2);
            end
        else
            % the newletter is the key sig. 
            if (newletter(1) == 'c')|(newletter(1) == 'f')
                % represent c as b# and f as e#. 
                note.accidental.String = accidentals(3);
            else
                % get rid of any accidentals
                note.accidental.String = accidentals(4);
            end
        end        
    end

    function [newnum, newletter] = chrdecrement(note)
        % takes a note struct and moves it up in the chromatic scale,
        % changing the identity of the note as well as adding an
        % accidental.
        
        % change the identity of the note:
        newletter = chromadd(note.letter, -1);
        if strcmp(newletter, 'b ')
            newnum = note.num-1;
        else
            newnum = note.num;
        end
        % (the letter and num of the note that this note is
        % being raised to.)
        
        % change the appearence of the note:
        % position of the note should change if the original accidental is
        % flat. 
        if note.accidental.String == accidentals(1)
            note.notehead.Vertices(:,2) = note.notehead.Vertices(:,2)+space/2;
            note.stem.Vertices(:,2) = note.stem.Vertices(:,2)+space/2;
            note.button.Position(2) = note.button.Position(2)-space/2;
            note.accidental.Position(2) = note.accidental.Position(2)-space/2;
        end
        % add an accidental if newletter is not in the key sig. 
        indeces = newletter == updatedscale;
        if ~sum(indeces(:,1).*indeces(:,2))
            % the newletter is NOT in the key sig. If it is white, add a
            % natural; if it is black, add a flat
            if newletter(2) == '#'
                % newletter is black; add a flat
                note.accidental.String = accidentals(1);
            else
                % newletter is white; add a natural
                note.accidental.String = accidentals(2);
            end
        else
            % the newletter is the key sig. 
            if (newletter(1) == 'b')|(newletter(1) == 'e')
                % represent b as cb and e as fb. 
                note.accidental.String = accidentals(1);
            else
                % get rid of any accidentals
                note.accidental.String = accidentals(4);
            end
        end        
    end

    function [nm, let] = increment(note)
        % takes a note struct and moves it up in the major scale,
        % changing the identity of the note as well as the graphical
        % representation. 
        
        % move up b# and e# extra because they are really just c and f,
        % respectively 
        if note.accidental.String == accidentals(3)
            if strcmp(note.letter, 'c ') | strcmp(note.letter, 'f ');
                note.notehead.Vertices(:,2) = note.notehead.Vertices(:,2)-space/2;
                note.stem.Vertices(:,2) = note.stem.Vertices(:,2)-space/2;
                note.button.Position(2) = note.button.Position(2)+space/2;
                note.accidental.Position(2) = note.accidental.Position(2)+space/2;
            end
        end
        
        note.accidental.String = accidentals(4);
        note.notehead.Vertices(:,2) = note.notehead.Vertices(:,2)-space/2;
        note.stem.Vertices(:,2) = note.stem.Vertices(:,2)-space/2;
        note.button.Position(2) = note.button.Position(2)+space/2;
        note.accidental.Position(2) = note.accidental.Position(2)+space/2;
        
        if note.letter(1) == 'b'
            nm = note.num+1;
        else
            nm = note.num;
        end
        let = majadd(note.letter, 1);
    end

    function [nm, let] = decrement(note)
        % takes a note struct and moves it down in the major scale,
        % changing the identity of the note as well as the graphical
        % representation. 
        
        % move down f flat and c flat extra because they are just e and b,
        % respectively
        if note.accidental.String == accidentals(1)
            if strcmp(note.letter, 'b ') | strcmp(note.letter, 'e ');
                note.notehead.Vertices(:,2) = note.notehead.Vertices(:,2)+space/2;
                note.stem.Vertices(:,2) = note.stem.Vertices(:,2)+space/2;
                note.button.Position(2) = note.button.Position(2)-space/2;
                note.accidental.Position(2) = note.accidental.Position(2)-space/2;
            end
        end
        
        note.accidental.String = accidentals(4);
        note.notehead.Vertices(:,2) = note.notehead.Vertices(:,2)+space/2;
        note.stem.Vertices(:,2) = note.stem.Vertices(:,2)+space/2;
        note.button.Position(2) = note.button.Position(2)-space/2;
        note.accidental.Position(2) = note.accidental.Position(2)-space/2;
        if note.letter(1) == 'c'
            nm = note.num-1;
        else
            nm = note.num;
        end
        let = majadd(note.letter, -1);
    end

%% composition functions

figaccidentals = ['b'; 'n'; '#'; ' '];

    function write(j)
        % write tenor(j), alto(j), and soprano(j) using the
        % bass(j) note and the figures.
        
        % replace the ' r' figure (which can only appear in the third
        % figure) with one of the other two figures, at random: 
        figs = bass(j).figure;
        if strcmp(figs(3,:), ' r')
            notes = [figs(1,:); figs(2,:)];
            figs(3,:) = notes(randi(2),:);
        end
        
        % reorder the figures in a random order:
        rand1 = randi(3); rand2 = randi(3);
        while rand2 == rand1
            rand2 = randi(3);
        end
        %debugger.String = [num2str(rand1) ' ' num2str(rand2)];
        figs = [figs(rand1,:); figs(rand2,:); figs((6-rand2-rand1),:)];
        
        % use figs to determine the letter names of each voice:
        intervals = str2num(figs(:,2))-1;
        notes = [majadd(bass(j).letter, intervals(1)); ...
            majadd(bass(j).letter, intervals(2)); majadd(bass(j).letter, intervals(3))];
        for jj = 1:3
            if ~strcmp(figs(jj,1), ' ')
                % the figure calls for an accidental. 
                indeces = updatedscale == notes(jj,:);
                index = find(indeces(:,1).*indeces(:,2));
                if strcmp(majorscale(index,:), updatedscale(index,:))
                    % the key sig calls for a natural. 
                    if figs(jj,1) == '#'
                        % the figure calls for a sharp: add one half step
                        notes(jj,:) = chromadd(notes(jj,:), 1);
                    else
                        if figs(jj,1) == 'b'
                            % the figure calls for a flat: add -1 halfstep
                            notes(jj,:) = chromadd(notes(jj,:), -1);
                        % else, the figure calls for a natural; nothing
                        % should be done
                        end
                    end
                else
                    if majorscale(index,1) == updatedscale(index,1)
                        % the key sig calls for a sharp. 
                        if figs(jj,1) == 'n'
                            % the figure calls for natural: add -1 halfstep
                            notes(jj,:) = chromadd(notes(jj,:), -1);
                        else
                            if figs(jj,1) == 'b'
                                % the figure calls for flat: add -2
                                % halfstep
                                notes(jj,:) = chromadd(notes(jj,:), -2);
                            % else, the figure calls for sharp: nothing
                            % should be done
                            end
                        end
                    else
                        % the key sig calls for a flat. 
                        if figs(jj,1) == '#'
                            % the figure calls for a sharp: add 2 halfstep
                            notes(jj,:) = chromadd(notes(jj,:), 2);
                        else
                            if figs(jj,1) == 'n'
                                % the figure calls for natural: add 1
                                % halfstep
                                notes(jj,:) = chromadd(notes(jj,:), 1);
                            % else the figure calls for a flat; do nothing
                            end
                        end
                    end
                end
            end
        end
        % now notes is a matrix containing the letter names for each voice
        % in the format [tenor; alto; soprano]
        
        % modify the tenor, alto, soprano voices:
        
        % only change notes that are inact (have not been set by the user)
        % tenor:
        if sum(tenor(j).stem.EdgeColor == inact) == 3
            % set note and visually add accidentals where applicable
            tenor(j).letter = notes(1,:);
            index = find(figs(1,1) == figaccidentals);
            tenor(j).accidental.String = accidentals(index);
            
            % set the octave number
            tenor(j).num = bass(j).num;   % the minimum it can possibly be
            if j > 1
                % minimize leapiness of the line by selecting the octave that
                % is closest to the previous note. This does not apply to the
                % first notes, j = 1.
                while abs(dist(tenor(j-1).letter, tenor(j-1).num, tenor(j).letter, tenor(j).num)) ...
                        > abs(dist(tenor(j-1).letter, tenor(j-1).num, tenor(j).letter, tenor(j).num+1))
                    tenor(j).num = tenor(j).num+1;
                end
            end
            % if a voice's note is lower than the lower voice's note, move it
            % up an octave to avoid voice crossings.
            while dist(bass(j).letter, bass(j).num, tenor(j).letter, tenor(j).num)<0
                tenor(j).num = tenor(j).num + 1;
            end
            
            % move the note to the correct position:
            stemtip = -stemheight;
            pos = (space/2)*intervals(1);
            if tenor(j).num >= 5
                pos = pos + (middlespace-2)*space;
                stemtip = -stemtip;
                tenor(j).stem.Vertices(:,1) = notexs(j);
            end
            pos = pos + 3.5*space*(tenor(j).num - bass(j).num); pos = -pos;
            size(tenor(j).notehead.Vertices(:,2))
            size(bass(j).notehead.Vertices(:,2))
            tenor(j).notehead.Vertices(:,2) = bass(j).notehead.Vertices(:,2) + pos;
            tenor(j).stem.Vertices(1,2) = bass(j).stem.Vertices(1,2) + pos;
            tenor(j).stem.Vertices(2,2) = tenor(j).stem.Vertices(1,2) + stemtip;
            tenor(j).button.Position(2) = bass(j).button.Position(2) - pos;
            tenor(j).accidental.Position(2) = bass(j).accidental.Position(2) - pos;
            
        end
        
        % alto
        if sum(alto(j).stem.EdgeColor == inact) == 3
            alto(j).letter = notes(2,:);
            index = find(figs(2,1) == figaccidentals);
            alto(j).accidental.String = accidentals(index);
        
            alto(j).num = tenor(j).num;
            if j > 1
                while abs(dist(alto(j-1).letter, alto(j-1).num, alto(j).letter, alto(j).num)) ...
                        > abs(dist(alto(j-1).letter, alto(j-1).num, alto(j).letter, alto(j).num+1))
                    alto(j).num = alto(j).num+1;
                end
            end
            while dist(tenor(j).letter, tenor(j).num, alto(j).letter, alto(j).num)<0
                alto(j).num = alto(j).num + 1;
            end
            
            % move the note to the correct position:
            stemtip = stemheight;
            pos = (space/2)*intervals(2);
            if alto(j).num >= 5
                pos = pos + (middlespace-2)*space;
                alto(j).stem.Vertices(:,1) = notexs(j);
            else
                stemtip = -stemtip;
                alto(j).stem.Vertices(:,1) = notexs(j) + 2*sqrt(R);
            end
            pos = pos + 3.5*space*(alto(j).num - bass(j).num); pos = -pos;
            alto(j).notehead.Vertices(:,2) = bass(j).notehead.Vertices(:,2) + pos;
            alto(j).stem.Vertices(1,2) = bass(j).stem.Vertices(1,2) + pos;
            alto(j).stem.Vertices(2,2) = alto(j).stem.Vertices(1,2) + stemtip;
            alto(j).button.Position(2) = bass(j).button.Position(2) - pos;
            alto(j).accidental.Position(2) = bass(j).accidental.Position(2) - pos;
                       
        end
        
        % soprano
        if sum(soprano(j).stem.EdgeColor == inact) == 3
            soprano(j).letter = notes(3,:);
            index = find(figs(3,1) == figaccidentals);
            soprano(j).accidental.String = accidentals(index);
            
            soprano(j).num = alto(j).num;
            if j > 1
                while abs(dist(soprano(j-1).letter, soprano(j-1).num, soprano(j).letter, soprano(j).num)) ...
                        > abs(dist(soprano(j-1).letter, soprano(j-1).num, soprano(j).letter, soprano(j).num+1))
                    soprano(j).num = soprano(j).num+1;
                end
            end
            while dist(alto(j).letter, alto(j).num, soprano(j).letter, soprano(j).num)<0
                soprano(j).num = soprano(j).num + 1;
            end
        
            % move the note to the correct position:
            stemtip = -stemheight;
            pos = (space/2)*intervals(3);
            if soprano(j).num >= 5
                pos = pos + (middlespace-2)*space;
                %stemtip = -stemtip;
            end
            pos = pos + 3.5*space*(soprano(j).num - bass(j).num); pos = -pos;
            soprano(j).notehead.Vertices(:,2) = bass(j).notehead.Vertices(:,2) + pos;
            soprano(j).stem.Vertices(1,2) = bass(j).stem.Vertices(1,2) + pos;
            soprano(j).stem.Vertices(2,2) = soprano(j).stem.Vertices(1,2) + stemtip;
            soprano(j).button.Position(2) = bass(j).button.Position(2) - pos;
            soprano(j).accidental.Position(2) = bass(j).accidental.Position(2) - pos;
        end                                        
    end

    function tot = leap()
       % quantify the amount of leap (notes being far apart) in each voice
       numnotes = 0; % the amount of notes that should be counted
       for j = 1:nbass
          if sum(bass(j).stem.EdgeColor == inact) < 3
              % the note should be counted 
              numnotes = numnotes + 1;
          end
       end
       tot = 0;
       for j = 2:numnotes
           tot = tot + abs(dist(tenor(j-1).letter, tenor(j-1).num, ...
               tenor(j).letter, tenor(j).num));
           tot = tot + abs(dist(alto(j-1).letter, alto(j-1).num, ...
               alto(j).letter, alto(j).num));
           tot = tot + abs(dist(soprano(j-1).letter, soprano(j-1).num, ...
               soprano(j).letter, soprano(j).num));
       end
       tot = tot/numnotes; % gives the "average leap"
    end

    function distance = dist(letter1, num1, letter2, num2)
        % allows the evaluation of distances between two notes, given their
        % letter name and octave number. 
        % distance is positive when 2 is higher than 1. 
        indeces1 = letter1 == orderedscale;
        index1 = find(indeces1(:,1).*indeces1(:,2));
        indeces2 = letter2 == orderedscale;
        index2 = find(indeces2(:,1).*indeces2(:,2));
        %13
        if num1 == num2
            distance = index2-index1;
        else
            if num2 > num1
                index1 = 12-index1;
                distance = 12*(num2-num1-1)+index1+index2;
            else
                index2 = 13-index2;
                distance = -1*(12*(num1-num2-1)+index1+index2);
            end
        end
        
    end

    function bool = isparallel(x1, x2, y1, y2)
        % determines if two pairs of notes exhibit parallel 5ths or 8ths
        % input are four note structs 
        % the x notes should be higher than the y notes
        
        % get the distance (interval) between notes: 
        dist1 = dist(x1.letter, x1.num, y1.letter, y1.num);
        dist2 = dist(x2.letter, x2.num, y2.letter, y2.num);
        
        bool = (dist1 == dist2) & ((mod(dist1,12)==7)|strcmp(x1.letter,y1.letter));
        % tests whether the intervals are the same (parallel) and whether
        % the intervals are either a 5th (7 half steps) or octave (letter
        % names are the same)
    end

    function parallels = checkuserparallels()
        % determines if the notes input by the user already contain
        % parallels. 
        j = 2; parallels = false;
        while (~parallels)&(j <= nbass)
            % has__ determines if __ voice has two user inputs one after
            % another at the current j. If not, it can't have any parallels 
            hastenor = (sum(tenor(j).stem.EdgeColor == inact) < 3) & ...
                (sum(tenor(j-1).stem.EdgeColor == inact) < 3);
            hasalto = (sum(alto(j).stem.EdgeColor == inact) < 3) & ...
                (sum(alto(j-1).stem.EdgeColor == inact) < 3);
            hassoprano = (sum(soprano(j).stem.EdgeColor == inact) < 3) & ...
                (sum(soprano(j-1).stem.EdgeColor == inact) < 3);
            
            % check for parallels in the tenor voice with bass, alto,
            % or soprano
            if hastenor
                parallels = parallels | isparallel(bass(j-1), bass(j), tenor(j-1), tenor(j));
                if hasalto
                    parallels = parallels | isparallel(tenor(j-1), tenor(j), alto(j-1), alto(j));
                end
                if hassoprano
                    parallels = parallels | isparallel(tenor(j-1), tenor(j), soprano(j-1), soprano(j));
                end
            end
            
            % check for parallels in the alto voice with bass or soprano
            % (tenor has already been checked) 
            if hasalto
                parallels = parallels | isparallel(bass(j-1), bass(j), alto(j-1), alto(j));
                if hassoprano
                    parallels = parallels | isparallel(alto(j-1), alto(j), soprano(j-1), soprano(j));
                end
            end
            
            % check for parallels in the soprano voice with the bass (all
            % other voices have already been checked)
            if hassoprano
                parallels = parallels | isparallel(bass(j-1), bass(j), soprano(j-1), soprano(j));
            end
            
            j = j+1;
        end
        
        if parallels
            % indicate where the parallels are (so that the user can change
            % them) by changing the color of the notes to errorcolor. 
            j = j-1;
            bass(j).notehead.FaceColor = errorcolor; 
            bass(j).notehead.EdgeColor = errorcolor;
            tenor(j).notehead.FaceColor = errorcolor; 
            tenor(j).notehead.EdgeColor = errorcolor;
            alto(j).notehead.FaceColor = errorcolor; 
            alto(j).notehead.EdgeColor = errorcolor;
            soprano(j).notehead.FaceColor = errorcolor; 
            soprano(j).notehead.EdgeColor = errorcolor;
            j = j-1;
            bass(j).notehead.FaceColor = errorcolor; 
            bass(j).notehead.EdgeColor = errorcolor;
            tenor(j).notehead.FaceColor = errorcolor; 
            tenor(j).notehead.EdgeColor = errorcolor;
            alto(j).notehead.FaceColor = errorcolor; 
            alto(j).notehead.EdgeColor = errorcolor;
            soprano(j).notehead.FaceColor = errorcolor; 
            soprano(j).notehead.EdgeColor = errorcolor;
        end
    end

    function updatefigures()
        % use the inputs of the text boxes to generate figures for each
        % bass note.
        
        for j = 1:nbass
            bass(j).figure = ['  '; '  '; '  ']; %clear previous data from the figure
            fig = {(bass(j).fig1.String), (bass(j).fig2.String), ...
                (bass(j).fig3.String)};
            % at first, fig contains strings with accidentals and numbers. 
            % after the for loop, this data should be moved into the figure
            % property of the bass note. 
            for index = 1:3
                if length(fig{index})>1
                    % the figure has an accidental, eg '#3'
                    bass(j).figure(index, :) = fig{index}
                else
                    if length(fig{index})>0
                        % the figure has one char, either a number or an
                        % accidental with an implied 3
                        if isempty(str2num(fig{index}))
                            % accidental with an implied 3:
                            bass(j).figure(index,:) = [fig{index}, '3'];
                        else
                            % number should be moved to figure property. 
                            % accidental should be set as ' ' to
                            % signify there is so accidental. 
                            bass(j).figure(index,:) = [' ', fig{index}];
                            %fig{index} = ' ';
                        end
                    %else
                        % the input figure is ''. 
                        % leave the figure property as '  ' for now. 
                    end
                end
            end
            
            % interpret the data that is now in the figure property: 
            if strcmp(bass(j).figure(1,:), '  ')
               % the first figure is empty, meaning the rest are empty. 
               % it must be set as the default: 
               bass(j).figure = [' 5'; ' 3'; ' r'];
               % 5 and 3 should be inserted, and then a repetition of
               % either 1, 5, or 3
            else
                if strcmp(bass(j).figure(1,2), '6')
                    if strcmp(bass(j).figure(2,:), '  ')
                        % if the only figure is a 6, assume 6-3, and the
                        % third should be a repetition of 1, 3, or 6
                        bass(j).figure(2,:) = ' 3';
                        bass(j).figure(3,:) = ' r';
                    else
                        if strcmp(bass(j).figure(2,2), '5')
                            % a 6-5 is a second inversion 7 chord
                            bass(j).figure(3,:) = ' 3';
                        else
                            % set the third figure as a repetition of one
                            % of the others
                            bass(j).figure(3,:) = ' r'
                        end
                    end
                else 
                    if strcmp(bass(j).figure(1,2), '4')
                        % there are two possibilities for 7 chords if the
                        % first figure is a 4:
                        if strcmp(bass(j).figure(2,2), '3')|strcmp(bass(j).figure(2,2), '2')
                            % in either case, this is a 7 chord and the
                            % remaining figure is a 6. 
                            bass(j).figure(3,:) = ' 6';
                        else
                            % this is not a 7 chord. if a figure is
                            % missing, assume it is a 6, so this is a 6-4 chord with
                            % the last figure being a repetition
                            if strcmp(bass(j).figure(2,:), '  ')
                                bass(j).figure(2,:) = ' 6';
                                bass(j).figure(3,:) = ' r';
                            end
                        end
                    else
                        if strcmp(bass(j).figure(1,2), '7')
                            % this is a 7 chord completed with 3 and 5:
                            bass(j).figure(2,:) = ' 5';
                            bass(j).figure(3,:) = ' 3';
                        else
                            if (bass(j).figure(1,2) == '3')|(bass(j).figure(1,2) == '5')
                                % if the top figure is a 3/5, the second
                                % figure is 3/5/blank, and the bottom
                                % figure is blank, assume this is a
                                % standard 5-3 chord
                                if (bass(j).figure(2,2) == '3')|(bass(j).figure(2,2) == '5')
                                    if strcmp(bass(j).figure(3,:), '  ')
                                        % only the last figure is missing;
                                        % replace it with repetition
                                        bass(j).figure(3,:) = ' r';
                                    end
                                else
                                    if strcmp(bass(j).figure(2,:), '  ')
                                        % two figures are missing; one of
                                        % them should be repetition and the
                                        % other should be either 3 or 5
                                        bass(j).figure(3,:) = ' r';
                                        if bass(j).figure(1,2) == '3'
                                            bass(j).figure(2,:) = ' 5';
                                        else
                                            bass(j).figure(2,:) = ' 3'
                                        end
                                    end
                                end
                            else
                                if strcmp(bass(j).figure(2,:), '  ')
                                    % if the top figure hasn't been covered
                                    % yet, assume it is an extension and the
                                    % rest of the chord should be completed by
                                    % 3 and 7:
                                    bass(j).figure(2,:) = ' 7';
                                    bass(j).figure(3,:) = ' 3';
                                else
                                    % if none of these cases are true, and
                                    % there is still a missing figure, set
                                    % the missing figure as a repetition:
                                    if strcmp(bass(j).figure(3,:), '  ')
                                        bass(j).figure(3,:) = ' r';
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end


%% other functions and data
    function newim = impose(base, addition, row, col)
        % imposes one grayscale image (addition) on top of another (base),
        % treating white as transparent. addition must be smaller than
        % base. addition is inserted at specified row and column, which
        % should not allow the addition to exceed the dimensions of the
        % base. 
        [H, W] = size(base);
        [h, w] = size(addition);
        % newim is a matrix the same size as base containing addition in
        % the desired row/column and ones (white) everywhere else. 
        newim = [ones(row, W); ones(h, col), addition, ones(h, W-w-col); ones(H-h-row, W)];
        size(newim);
        newim = newim.*base;
    end
end