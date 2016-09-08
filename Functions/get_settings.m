function settings = get_settings(handles)

% Get dimensions
settings.nmWid = str2num(get(handles.nmWid,'String'));

% Get filter settings
settings.invert = get(handles.invertColor,'Value');
settings.thnm = str2num(get(handles.tophatSize,'String'));
settings.noisenm = str2num(get(handles.noiseArea,'String'));
settings.maxBranchSizenm = str2num(get(handles.maxBranchSize,'String'));
% settings.maxStubLennm = str2num(get(handles.maxStubLen,'String'));
settings.globalThresh = str2num(get(handles.globalThresh,'String'));

% Get figure display settings
settings.CEDFig = get(handles.CEDFig,'Value');
settings.topHatFig = get(handles.topHatFig,'Value');
settings.threshFig = get(handles.threshFig,'Value');
settings.noiseRemFig = get(handles.noiseRemFig,'Value');
settings.skelFig = get(handles.skelFig,'Value');
settings.skelTrimFig = get(handles.skelTrimFig,'Value');
settings.threshMethod = get(handles.threshMethod,'Value');

settings.figSave = get(handles.saveFigs,'Value');

% Build the Coherence Filter options structure
Options = struct();
Options.Scheme = 'I';
settings.gaussnm = str2num(get(handles.gauss,'String'));
settings.rhonm = str2num(get(handles.rho,'String'));
% Options.sigma = gausspix;
% Options.rho = rhopix;
Options.T = str2num(get(handles.difftime,'String'));
Options.dt = 0.15;
% Options.eigenmode = 5;
Options.eigenmode = 0;
Options.C = 1E-10;

settings.Options = Options;

% OP2D calculation settings
settings.gridStepnm = str2num(get(handles.gridStep,'String'));
settings.frameStepnmWide = str2num(get(handles.frameStep,'String'));

% Fiber Width calc settings
% settings.fibWidSamps = str2num(get(handles.fibWidSamps,'String'));
settings.fibWidSamps2 = 15;

% Gif Export Settings
settings.initDelay = 1;
settings.CEDStepDelay = 0.1;
settings.CEDFinalDelay = 0.8;
settings.skelDelay = 4;
settings.plotDelay = 0.5;
settings.plotFinal = 3;

end