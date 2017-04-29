figure; hold on;
% f=55;
% plot(ims.Fibers(f).xy_nm(1,:)',ims.Fibers(f).xy_nm(2,:)','-k')
% plot(ims.Fibers(f).xing_pts(:,1),ims.Fibers(f).xing_pts(:,2),'or')
ax=gca
ax.get
axis equal
ax.YDir='reverse'
for f = [3,55,64];
chains=ims.Chains(ims.ChainLabels==f,:);
for c = 1:length(chains);
plot(ax,chains(c,[1,3]),chains(c,[2,4]),'-b');
end
end