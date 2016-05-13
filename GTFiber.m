% Copyright (C) 2016 Nils Persson
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function varargout = GTFiber(varargin)
% GTFIBER MATLAB code for GTFiber.fig
%      GTFIBER, by itself, creates a new GTFIBER or raises the existing
%      singleton*.
%
%      H = GTFIBER returns the handle to a new GTFIBER or the handle to
%      the existing singleton*.
%
%      GTFIBER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GTFIBER.M with the given input arguments.
%
%      GTFIBER('Property','Value',...) creates a new GTFIBER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GTFiber_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GTFiber_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GTFiber

% Last Modified by GUIDE v2.5 05-May-2016 12:15:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GTFiber_OpeningFcn, ...
                   'gui_OutputFcn',  @GTFiber_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GTFiber is made visible.
function GTFiber_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GTFiber (see VARARGIN)

% Choose default command line output for GTFiber
handles.output = hObject;
addpath('Functions')
addpath('Functions/coherencefilter_version5b')
addpath('Functions/cell2csv')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GTFiber wait for user response (see UIRESUME)
% uiwait(handles.mainFig);


% --- Outputs from this function are returned to the command line.
function varargout = GTFiber_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Main_Callback(hObject, eventdata, handles)
% hObject    handle to Main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, folderpath] = uigetfile({'*.jpg;*.jpeg;*.tif;*.tiff;*.png;*.gif;*.bmp','All Image Files'});
if isequal(filename, 0); return; end % Cancel button pressed

% Prompt user for the image width
prompt = {'Enter image width in nanometers, with no commas (ex. 5000):'};
dlg_title = 'Image Scale';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
set(handles.nmWid,'String',answer{1})

imfile = [folderpath, filename];

% Initialize the internal image data structure, "ims"
handles.ims = initImgData(imfile);
set(handles.fileNameBox,'String',handles.ims.imName);

figure; imshow(handles.ims.img)
disp('performed initial thresholding')

guidata(hObject, handles);


% --- Executes on button press in Coherence_Filter.
function Coherence_Filter_Callback(hObject, eventdata, handles)
% hObject    handle to Coherence_Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'ims')
    noload = errordlg('Go to File>Load Image to load an image before filtering.');
    return
end

settings = get_settings(handles);
[settings, ims] = pix_settings(settings,handles.ims);
handles.ims = ims;

handles.ims = main_filter(handles.ims,settings);

ims = handles.ims;
% save('test','ims')

guidata(hObject, handles);

% --- Executes on button press in AngMap.
function AngMap_Callback(hObject, eventdata, handles)
% hObject    handle to AngMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'ims')
    noload = errordlg('Go to File>Load Image to load an image before filtering.');
    return
end

if ~isfield(handles.ims,'AngMap')
    nofilt = errordlg('"Run Filter" must be executed before results can be displayed');
    return
end

% handles.ims.nmWid = str2num(get(handles.nmWid,'String'));
% handles.ims.pixWid = size(handles.img,2);
% handles.ims.nmPix = handles.ims.nmWid/handles.ims.pixWid;

AngleColorMap(handles.ims.AngMap,handles.ims.skelTrim);


% --- Executes on button press in op2d.
function op2d_Callback(hObject, eventdata, handles)
% hObject    handle to op2d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'ims')
    noload = errordlg('Go to File>Load Image to load an image before filtering.');
    return
end

if ~isfield(handles.ims,'AngMap')
    nofilt = errordlg('"Run Filter" must be executed before results can be displayed');
    return
end

settings = get_settings(handles);
settings = pix_settings(settings,handles.ims);
settings.figSwitch = 1; % display figure if it's called by this button
settings.figSave = 0;   % don't try to save figure when called by this button
[handles.ims.frames, handles.ims.sfull, handles.ims.smod] = op2d_am(handles.ims, settings);



% --- Executes on button press in runDir.
function runDir_Callback(hObject, eventdata, handles)
% hObject    handle to runDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get folder and save file name
folderPath = uigetdir;
if isequal(folderPath, 0); return; end % Cancel button pressed
if ispc
    separator = '\';
else
    separator = '/';
end

folderPath = [folderPath, separator];

% Get name for results file
prompt = {'Save results with file name (no extension necessary):'};
dlg_title = 'Save File Name';
num_lines = 1;
fileName = inputdlg(prompt,dlg_title,num_lines);
saveFilePath = [folderPath, fileName{1}, '.csv'];

% Build up settings from GUI, turn off all figure displays
settings = get_settings(handles);
settings.CEDFig = 0;
settings.topHatFig = 0;
settings.threshFig = 0;
settings.noiseRemFig = 0;
settings.skelFig = 0;
settings.skelTrimFig = 0;
settings.figSwitch = 0;
settings.figSave = get(handles.saveFigs,'Value');
settings.fullOP = 1;

csvCell = runDir(folderPath,settings);
cell2csv(saveFilePath, csvCell, ',', 1999, '.');
% save([folderPath, fileName{1}, '.mat'],'csvCell')



function gauss_Callback(hObject, eventdata, handles)
% hObject    handle to gauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gauss as text
%        str2double(get(hObject,'String')) returns contents of gauss as a double


% --- Executes during object creation, after setting all properties.
function gauss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rho_Callback(hObject, eventdata, handles)
% hObject    handle to rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rho as text
%        str2double(get(hObject,'String')) returns contents of rho as a double


% --- Executes during object creation, after setting all properties.
function rho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function difftime_Callback(hObject, eventdata, handles)
% hObject    handle to difftime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of difftime as text
%        str2double(get(hObject,'String')) returns contents of difftime as a double


% --- Executes during object creation, after setting all properties.
function difftime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to difftime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noiseArea_Callback(hObject, eventdata, handles)
% hObject    handle to noiseArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noiseArea as text
%        str2double(get(hObject,'String')) returns contents of noiseArea as a double


% --- Executes during object creation, after setting all properties.
function noiseArea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noiseArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function minFibLen_Callback(hObject, eventdata, handles)
% hObject    handle to minFibLenText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minFibLenText as text
%        str2double(get(hObject,'String')) returns contents of minFibLenText as a double


% --- Executes during object creation, after setting all properties.
function minFibLen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minFibLenText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tophatSize_Callback(hObject, eventdata, handles)
% hObject    handle to tophatSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tophatSize as text
%        str2double(get(hObject,'String')) returns contents of tophatSize as a double


% --- Executes during object creation, after setting all properties.
function tophatSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tophatSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gridStep_Callback(hObject, eventdata, handles)
% hObject    handle to gridStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gridStep as text
%        str2double(get(hObject,'String')) returns contents of gridStep as a double


% --- Executes during object creation, after setting all properties.
function gridStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frameStep_Callback(hObject, eventdata, handles)
% hObject    handle to frameStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameStep as text
%        str2double(get(hObject,'String')) returns contents of frameStep as a double


% --- Executes during object creation, after setting all properties.
function frameStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nmWid_Callback(hObject, eventdata, handles)
% hObject    handle to nmWid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nmWid as text
%        str2double(get(hObject,'String')) returns contents of nmWid as a double


% --- Executes during object creation, after setting all properties.
function nmWid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nmWid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CEDFig.
function CEDFig_Callback(hObject, eventdata, handles)
% hObject    handle to CEDFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CEDFig


% --- Executes on button press in topHatFig.
function topHatFig_Callback(hObject, eventdata, handles)
% hObject    handle to topHatFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of topHatFig


% --- Executes on button press in noiseRemFig.
function noiseRemFig_Callback(hObject, eventdata, handles)
% hObject    handle to noiseRemFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of noiseRemFig


% --- Executes on button press in threshFig.
function threshFig_Callback(hObject, eventdata, handles)
% hObject    handle to threshFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of threshFig


% --- Executes on button press in skelTrimFig.
function skelTrimFig_Callback(hObject, eventdata, handles)
% hObject    handle to skelTrimFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skelTrimFig


% --- Executes on selection change in threshMethod.
function threshMethod_Callback(hObject, eventdata, handles)
% hObject    handle to threshMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns threshMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from threshMethod


% --- Executes during object creation, after setting all properties.
function threshMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function globalThresh_Callback(hObject, eventdata, handles)
% hObject    handle to globalThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of globalThresh as text
%        str2double(get(hObject,'String')) returns contents of globalThresh as a double


% --- Executes during object creation, after setting all properties.
function globalThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to globalThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxBranchSize_Callback(hObject, eventdata, handles)
% hObject    handle to maxBranchSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxBranchSize as text
%        str2double(get(hObject,'String')) returns contents of maxBranchSize as a double


% --- Executes during object creation, after setting all properties.
function maxBranchSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxBranchSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in skelFig.
function skelFig_Callback(hObject, eventdata, handles)
% hObject    handle to skelFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skelFig



% --- Executes on button press in saveFigs.
function saveFigs_Callback(hObject, eventdata, handles)
% hObject    handle to saveFigs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveFigs


% --- Executes during object creation, after setting all properties.
function mainFig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function widthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to widthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
