function out = objective_count_length(Params,imFile,nmWid,target)

% Okeeeee dokeeeeeeee
% Params:                               LB      |      UB     

% 1. Gaussian Smoothing (nm)               1       |      100
% 2. Orientation Smoothing (nm)            1       |      100
% 3. Diffusion Time (s)                    0.5     |       10
% 4. Top Hat Size (nm)                     1       |      100
% 5. Global Thresh                         0.2     |      0.8
% 6. Noise Removal (nm^2)                  100     |      5000
% 7. Fringe Removal (nm)                   0       |      300

% 8. Min Width (nm)                        0       |      100
% 9. Max Width (nm)                        50      |      Inf
% 10. Max Bend Angle (deg.)                 0       |      180
% 11. Step Length (pix)                     1       |      10

ims = initImgData(imFile);
settings = get_settings_nogui(Params,nmWid);
settings.figSwitch = 0;
settings.figSave = 0;
settings.fullOP = 1;
[settings, ims] = pix_settings(settings,ims);

auto_handles.ims = ims;
auto_handles.settings = settings;
auto_handles = main_filter(auto_handles);
ims = auto_handles.ims;

ims = StitchFibers2(ims,settings);
ims = FiberLengths(ims,settings);
FiberData = [ims.Fibers(:).Length]';
count_length = [length(FiberData),mean(FiberData)];
out = norm(count_length-target);

end


function settings = get_settings_nogui(Params,nmWid);

% Get dimensions
settings.nmWid = nmWid; %str2num(get(handles.nmWid,'String'));

% Get filter settings
settings.invert = 0; %get(handles.invertColor,'Value');
settings.thnm = Params(4); %str2num(get(handles.tophatSize,'String'));
settings.noisenm = Params(6); %str2num(get(handles.noiseArea,'String'));
settings.maxBranchSizenm = Params(7); %str2num(get(handles.maxBranchSize,'String'));
settings.globalThresh = Params(5); %str2num(get(handles.globalThresh,'String'));
settings.threshMethod = 2; %get(handles.threshMethod,'Value');

settings.figSave = 0; %get(handles.saveFigs,'Value');

% Build the Coherence Filter options structure
Options = struct();
Options.Scheme = 'I';
settings.gaussnm = Params(1); %str2num(get(handles.gauss,'String'));
settings.rhonm = Params(2); %str2num(get(handles.rho,'String'));
% Options.sigma = gausspix;
% Options.rho = rhopix;
Options.T = Params(3); %str2num(get(handles.difftime,'String'));
Options.dt = 0.15;
% Options.eigenmode = 5;
Options.eigenmode = 0;
Options.C = 1E-10;

settings.Options = Options;


% OP2D calculation settings
settings.gridStepnm = 400; %str2num(get(handles.gridStep,'String'));
settings.frameStepnmWide = 200; %str2num(get(handles.frameStep,'String'));

% Fiber Width calc settings
% settings.fibWidSamps = str2num(get(handles.fibWidSamps,'String'));
settings.fibWidSamps2 = 15;


% Fiber Fitting Settings
settings.fiberStep = Params(11); %ceil(str2num(get(handles.fiberStep,'String')));
settings.maxAngleDeg = Params(10); %str2num(get(handles.maxAngleDeg,'String'));
% settings.curvLen = str2num(get(handles.curvLen,'String'));
settings.minWidthnm = Params(8); %str2num(get(handles.minWidth,'String'));
settings.maxWidthnm = Params(9); %str2num(get(handles.maxWidth,'String'));


% Gif Export Settings
settings.initDelay = 1;
settings.CEDStepDelay = 0.1;
settings.CEDFinalDelay = 0.8;
settings.skelDelay = 4;
settings.plotDelay = 0.5;
settings.plotFinal = 3;

end