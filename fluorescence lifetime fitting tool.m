clear all;
close all;

folder_name = uigetdir('C:\');
a=dir(folder_name);
[Nfile, ~]=size(a);

figure;
hdl1=gcf;

bin_width=0.01; %%%
hist_bin=(0.004:bin_width:20);
hist_bin=hist_bin';

x_min=4.5;
x_min_index=floor(x_min/bin_width);
hist_bin_cut=hist_bin(x_min_index:end);
tau_all=zeros(Nfile-2,1);

Nphoton=zeros(Nfile-2,1);

for i=3:Nfile;
    dtimes=load([folder_name '\' a(i).name]);
    [Nphoton(i),~]=size(dtimes);
    
    dhist=hist(dtimes,hist_bin);
    dhist(1)=0;
    dhist=dhist';
    dhist_cut=dhist(x_min_index:end);
        
    fo = fitoptions('Method','NonlinearLeastSquares',...
        'Lower',[0,0,0],...
        'Upper',[Inf,Inf, Inf],...
        'StartPoint',[1 1 1]);
    ft = fittype('a*exp(-x/tau)+y0','options',fo);
    
    [c2,gof] = fit(hist_bin_cut,dhist_cut,ft);
    c2

    figure(hdl1);

    plot(hist_bin,dhist);
    title([folder_name '\' a(i).name]);

    hold on;
    plot(hist_bin_cut,dhist_cut,'r');
    title([folder_name '\' a(i).name]);
    
    plot(c2,'c');
    hold off;

    tau_all(i-2)=double(c2.tau);
    save([folder_name '\' 'tau_all.dat'],'tau_all','-ascii');
    
%     input('sdf');
end

tau_hist_bin=(0:0.2:10); %%%%
tau_hist=hist(tau_all,tau_hist_bin);
[Ntau,~]=size(tau_all);
tau_sigma=std(tau_all(:));
tau_mean=mean(tau_all(:));
figure;
bar(tau_hist_bin,tau_hist,'r');
legend([num2str(Ntau) ' molecules, std=' num2str(tau_sigma) ', mean=' num2str(tau_mean)]);
output=[tau_hist_bin' tau_hist'];
save([folder_name '\' 'tau_hist.dat'],'output','-ascii');

figure;
hist(Nphoton);
title(num2str(mean(Nphoton)));

