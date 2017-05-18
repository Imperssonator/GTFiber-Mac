im_path = '/Users/Imperssonator/Google Drive/Kaylie/Fiber Growth master/For FiberApp/S2U0T20B2D0126.001.tif';
fa_path = '/Users/Imperssonator/Google Drive/Kaylie/Fiber Growth master/For FiberApp/S2U0T20B2D0126.001a.mat';
nmWid = 5000;

x0 = [...
10;
30;
3;
30;
1500;
80;
80;
0.1;
3];

lb = [...
1;
1;
0.5;
1;
100;
0;
0;
0;
2];

ub = [...
100;
100;
10;
100;
5000;
300;
500;
0.2;
10];

del = [...
10;
10;
2;
10;
500;
10;
10;
0.01;
1];

ofun = @(p) objective_overlap(p,im_path,nmWid,fa_path);

opt_params = sensitive_optimization(ofun,x0,lb,ub,del);