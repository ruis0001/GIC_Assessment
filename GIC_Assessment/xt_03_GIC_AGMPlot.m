load('.\results\ALGM.mat')

% subplot(2,2,1)
% length = [Line500kvTotalLength_RC Line230kvTotalLength_RC Line115kvbelowTotalLength_RC;...
%           Line500kvTotalLength_noRC Line230kvTotalLength_noRC Line115kvbelowTotalLength_noRC];
% bar(length','hist')
% title('')
%           
% subplot(2,1,1)
% length1 = [Line500kvTotalLength_noRC Line230kvTotalLength_noRC Line115kvbelowTotalLength_noRC;...
%           Line500kvLength_frd_noRC Line230kvLength_frd_noRC Line115kvbelowLength_frd_noRC;...
%           Line500kvLength_mixed_noRC Line230kvLength_mixed_noRC Line115kvbelowLength_mixed_noRC;...
%           Line500kvLength_noavg_noRC Line230kvLength_noavg_noRC Line115kvbelowLength_noavg_noRC;...
%           Line500kvLength_smooth_noRC Line230kvLength_smooth_noRC Line115kvbelowLength_smooth_noRC;...
%           Line500kvLength_noavg_int_noRC Line230kvLength_noavg_int_noRC Line115kvbelowLength_noavg_int_noRC;...
%           Line500kvLength_smooth_int_noRC Line230kvLength_smooth_int_noRC Line115kvbelowLength_smooth_int_noRC];
% bar(length1','hist')
% 
% subplot(2,1,2)
% length2 = [Line500kvTotalLength_RC Line230kvTotalLength_RC Line115kvbelowTotalLength_RC;...
%           Line500kvLength_frd_RC Line230kvLength_frd_RC Line115kvbelowLength_frd_RC;...
%           Line500kvLength_mixed_RC Line230kvLength_mixed_RC Line115kvbelowLength_mixed_RC;...
%           Line500kvLength_noavg_RC Line230kvLength_noavg_RC Line115kvbelowLength_noavg_RC;...
%           Line500kvLength_smooth_RC Line230kvLength_smooth_RC Line115kvbelowLength_smooth_RC;...
%           Line500kvLength_noavg_int_RC Line230kvLength_noavg_int_RC Line115kvbelowLength_noavg_int_RC;...
%           Line500kvLength_smooth_int_RC Line230kvLength_smooth_int_RC Line115kvbelowLength_smooth_int_RC];
% bar(length2','hist')

%% 115 kV
Line115kvbelowAGMmean_frd_diff = 100*(Line115kvbelowAGMmean_frd_RC-Line115kvbelowAGMmean_frd_noRC)./Line115kvbelowAGMmean_frd_noRC;
Line115kvbelowAGMmean_mixed_diff = 100*(Line115kvbelowAGMmean_mixed_RC-Line115kvbelowAGMmean_mixed_noRC)./Line115kvbelowAGMmean_mixed_noRC;
Line115kvbelowAGMmean_noavg_diff = 100*(Line115kvbelowAGMmean_noavg_RC-Line115kvbelowAGMmean_noavg_noRC)./Line115kvbelowAGMmean_noavg_noRC;
Line115kvbelowAGMmean_smooth_diff = 100*(Line115kvbelowAGMmean_smooth_RC-Line115kvbelowAGMmean_smooth_noRC)./Line115kvbelowAGMmean_smooth_noRC;
Line115kvbelowAGMmean_noavg_int_diff = 100*(Line115kvbelowAGMmean_noavg_int_RC-Line115kvbelowAGMmean_noavg_int_noRC)./Line115kvbelowAGMmean_noavg_int_noRC;
Line115kvbelowAGMmean_smooth_int_diff = 100*(Line115kvbelowAGMmean_smooth_int_RC-Line115kvbelowAGMmean_smooth_int_noRC)./Line115kvbelowAGMmean_smooth_int_noRC;
% plot(abs(Line115kvbelowAGMmean_frd_diff))
% hold on
% plot(abs(Line115kvbelowAGMmean_mixed_diff))
% plot(abs(Line115kvbelowAGMmean_noavg_diff))
% plot(abs(Line115kvbelowAGMmean_smooth_diff))
% plot(abs(Line115kvbelowAGMmean_noavg_int_diff))
% plot(abs(Line115kvbelowAGMmean_smooth_int_diff))
% plot(abs(SystemEfield2)+90,'k') % Eastward FRD E-field

mean115kvbelow = [mean(abs(Line115kvbelowAGMmean_frd_diff)) mean(abs(Line115kvbelowAGMmean_mixed_diff)) mean(abs(Line115kvbelowAGMmean_noavg_diff)) mean(abs(Line115kvbelowAGMmean_smooth_diff)) mean(abs(Line115kvbelowAGMmean_noavg_int_diff)) mean(abs(Line115kvbelowAGMmean_smooth_int_diff))];
% 
% plot([abs(Line115kvbelowAGMmean_frd_diff(375:615)) abs(Line115kvbelowAGMmean_frd_diff(1125:1515))])
% hold on
% plot([abs(Line115kvbelowAGMmean_mixed_diff(375:615)) abs(Line115kvbelowAGMmean_mixed_diff(1125:end))])
% plot([abs(Line115kvbelowAGMmean_noavg_diff(375:615)) abs(Line115kvbelowAGMmean_noavg_diff(1125:1515))])
% plot([abs(Line115kvbelowAGMmean_smooth_diff(375:615)) abs(Line115kvbelowAGMmean_smooth_diff(1125:1515))])
% plot([abs(Line115kvbelowAGMmean_noavg_int_diff(375:615)) abs(Line115kvbelowAGMmean_noavg_int_diff(1125:1515))])
% plot([abs(Line115kvbelowAGMmean_smooth_int_diff(375:615)) abs(Line115kvbelowAGMmean_smooth_int_diff(1125:1515))])
% plot([abs(SystemEfield2(375:615))+50 abs(SystemEfield2(1125:1515))+50],'k')

mean115kvbelowpeak = [mean([abs(Line115kvbelowAGMmean_frd_diff(375:615)) abs(Line115kvbelowAGMmean_frd_diff(1125:1515))])...
                      mean([abs(Line115kvbelowAGMmean_mixed_diff(375:615)) abs(Line115kvbelowAGMmean_mixed_diff(1125:end))])...
                      mean([abs(Line115kvbelowAGMmean_noavg_diff(375:615)) abs(Line115kvbelowAGMmean_noavg_diff(1125:1515))])...
                      mean([abs(Line115kvbelowAGMmean_smooth_diff(375:615)) abs(Line115kvbelowAGMmean_smooth_diff(1125:1515))])...
                      mean([abs(Line115kvbelowAGMmean_noavg_int_diff(375:615)) abs(Line115kvbelowAGMmean_noavg_int_diff(1125:1515))])...
                      mean([abs(Line115kvbelowAGMmean_smooth_int_diff(375:615)) abs(Line115kvbelowAGMmean_smooth_int_diff(1125:1515))])];

%% 230 kV
Line230kvAGMmean_frd_diff = 100*(Line230kvAGMmean_frd_RC-Line230kvAGMmean_frd_noRC)./Line230kvAGMmean_frd_noRC;
Line230kvAGMmean_mixed_diff = 100*(Line230kvAGMmean_mixed_RC-Line230kvAGMmean_mixed_noRC)./Line230kvAGMmean_mixed_noRC;
Line230kvAGMmean_noavg_diff = 100*(Line230kvAGMmean_noavg_RC-Line230kvAGMmean_noavg_noRC)./Line230kvAGMmean_noavg_noRC;
Line230kvAGMmean_smooth_diff = 100*(Line230kvAGMmean_smooth_RC-Line230kvAGMmean_smooth_noRC)./Line230kvAGMmean_smooth_noRC;
Line230kvAGMmean_noavg_int_diff = 100*(Line230kvAGMmean_noavg_int_RC-Line230kvAGMmean_noavg_int_noRC)./Line230kvAGMmean_noavg_int_noRC;
Line230kvAGMmean_smooth_int_diff = 100*(Line230kvAGMmean_smooth_int_RC-Line230kvAGMmean_smooth_int_noRC)./Line230kvAGMmean_smooth_int_noRC;
% plot(abs(Line230kvAGMmean_frd_diff))
% hold on
% plot(abs(Line230kvAGMmean_mixed_diff))
% plot(abs(Line230kvAGMmean_noavg_diff))
% plot(abs(Line230kvAGMmean_smooth_diff))
% plot(abs(Line230kvAGMmean_noavg_int_diff))
% plot(abs(Line230kvAGMmean_smooth_int_diff))
% plot(abs(SystemEfield2)+90,'k') % Eastward FRD E-field

mean230kv = [mean(abs(Line230kvAGMmean_frd_diff)) mean(abs(Line230kvAGMmean_mixed_diff)) mean(abs(Line230kvAGMmean_noavg_diff)) mean(abs(Line230kvAGMmean_smooth_diff)) mean(abs(Line230kvAGMmean_noavg_int_diff)) mean(abs(Line230kvAGMmean_smooth_int_diff))];
% 
% plot([abs(Line230kvAGMmean_frd_diff(375:615)) abs(Line230kvAGMmean_frd_diff(1125:1515))])
% hold on
% plot([abs(Line230kvAGMmean_mixed_diff(375:615)) abs(Line230kvAGMmean_mixed_diff(1125:end))])
% plot([abs(Line230kvAGMmean_noavg_diff(375:615)) abs(Line230kvAGMmean_noavg_diff(1125:1515))])
% plot([abs(Line230kvAGMmean_smooth_diff(375:615)) abs(Line230kvAGMmean_smooth_diff(1125:1515))])
% plot([abs(Line230kvAGMmean_noavg_int_diff(375:615)) abs(Line230kvAGMmean_noavg_int_diff(1125:1515))])
% plot([abs(Line230kvAGMmean_smooth_int_diff(375:615)) abs(Line230kvAGMmean_smooth_int_diff(1125:1515))])
% plot([abs(SystemEfield2(375:615))+50 abs(SystemEfield2(1125:1515))+50],'k')

mean230kvpeak = [mean([abs(Line230kvAGMmean_frd_diff(375:615)) abs(Line230kvAGMmean_frd_diff(1125:1515))])...
                 mean([abs(Line230kvAGMmean_mixed_diff(375:615)) abs(Line230kvAGMmean_mixed_diff(1125:end))])...
                 mean([abs(Line230kvAGMmean_noavg_diff(375:615)) abs(Line230kvAGMmean_noavg_diff(1125:1515))])...
                 mean([abs(Line230kvAGMmean_smooth_diff(375:615)) abs(Line230kvAGMmean_smooth_diff(1125:1515))])...
                 mean([abs(Line230kvAGMmean_noavg_int_diff(375:615)) abs(Line230kvAGMmean_noavg_int_diff(1125:1515))])...
                 mean([abs(Line230kvAGMmean_smooth_int_diff(375:615)) abs(Line230kvAGMmean_smooth_int_diff(1125:1515))])];

%% 500 kV
Line500kvAGMmean_frd_diff = 100*(Line500kvAGMmean_frd_RC-Line500kvAGMmean_frd_noRC)./Line500kvAGMmean_frd_noRC;
Line500kvAGMmean_mixed_diff = 100*(Line500kvAGMmean_mixed_RC-Line500kvAGMmean_mixed_noRC)./Line500kvAGMmean_mixed_noRC;
Line500kvAGMmean_noavg_diff = 100*(Line500kvAGMmean_noavg_RC-Line500kvAGMmean_noavg_noRC)./Line500kvAGMmean_noavg_noRC;
Line500kvAGMmean_smooth_diff = 100*(Line500kvAGMmean_smooth_RC-Line500kvAGMmean_smooth_noRC)./Line500kvAGMmean_smooth_noRC;
Line500kvAGMmean_noavg_int_diff = 100*(Line500kvAGMmean_noavg_int_RC-Line500kvAGMmean_noavg_int_noRC)./Line500kvAGMmean_noavg_int_noRC;
Line500kvAGMmean_smooth_int_diff = 100*(Line500kvAGMmean_smooth_int_RC-Line500kvAGMmean_smooth_int_noRC)./Line500kvAGMmean_smooth_int_noRC;
% plot(abs(Line500kvAGMmean_frd_diff))
% hold on
% plot(abs(Line500kvAGMmean_mixed_diff))
% plot(abs(Line500kvAGMmean_noavg_diff))
% plot(abs(Line500kvAGMmean_smooth_diff))
% plot(abs(Line500kvAGMmean_noavg_int_diff))
% plot(abs(Line500kvAGMmean_smooth_int_diff))
% plot(abs(SystemEfield2)+90,'k') % Eastward FRD E-field

mean500kv = [mean(abs(Line500kvAGMmean_frd_diff)) mean(abs(Line500kvAGMmean_mixed_diff)) mean(abs(Line500kvAGMmean_noavg_diff)) mean(abs(Line500kvAGMmean_smooth_diff)) mean(abs(Line500kvAGMmean_noavg_int_diff)) mean(abs(Line500kvAGMmean_smooth_int_diff))];
% 
% plot([abs(Line500kvAGMmean_frd_diff(375:615)) abs(Line500kvAGMmean_frd_diff(1125:1515))])
% hold on
% plot([abs(Line500kvAGMmean_mixed_diff(375:615)) abs(Line500kvAGMmean_mixed_diff(1125:end))])
% plot([abs(Line500kvAGMmean_noavg_diff(375:615)) abs(Line500kvAGMmean_noavg_diff(1125:1515))])
% plot([abs(Line500kvAGMmean_smooth_diff(375:615)) abs(Line500kvAGMmean_smooth_diff(1125:1515))])
% plot([abs(Line500kvAGMmean_noavg_int_diff(375:615)) abs(Line500kvAGMmean_noavg_int_diff(1125:1515))])
% plot([abs(Line500kvAGMmean_smooth_int_diff(375:615)) abs(Line500kvAGMmean_smooth_int_diff(1125:1515))])
% plot([abs(SystemEfield2(375:615))+50 abs(SystemEfield2(1125:1515))+50],'k')

mean500kvpeak = [mean([abs(Line500kvAGMmean_frd_diff(375:615)) abs(Line500kvAGMmean_frd_diff(1125:1515))])...
                 mean([abs(Line500kvAGMmean_mixed_diff(375:615)) abs(Line500kvAGMmean_mixed_diff(1125:end))])...
                 mean([abs(Line500kvAGMmean_noavg_diff(375:615)) abs(Line500kvAGMmean_noavg_diff(1125:1515))])...
                 mean([abs(Line500kvAGMmean_smooth_diff(375:615)) abs(Line500kvAGMmean_smooth_diff(1125:1515))])...
                 mean([abs(Line500kvAGMmean_noavg_int_diff(375:615)) abs(Line500kvAGMmean_noavg_int_diff(1125:1515))])...
                 mean([abs(Line500kvAGMmean_smooth_int_diff(375:615)) abs(Line500kvAGMmean_smooth_int_diff(1125:1515))])];
                  
%% EFV_coefficient variations
% frd
sumEFV_frd_noRC = sum(abs(EFV_coefficient_frd_noRC(:,:,:)),1);
sumEFV_frd_noRC = sumEFV_frd_noRC(1,:);
sumEFV_frd_RC = sum(abs(EFV_coefficient_frd_RC(:,:,:)),1);
sumEFV_frd_RC = sumEFV_frd_RC(1,:);
sumEFV_frd_vari = abs((sumEFV_frd_RC-sumEFV_frd_noRC));
sumEFV_frd_variation = sumEFV_frd_vari./sumEFV_frd_noRC;
sumEFV_frd_variation = [sumEFV_frd_vari(1:2:length(sumEFV_frd_vari));sumEFV_frd_variation(1:2:length(sumEFV_frd_vari));sumEFV_frd_vari(2:2:length(sumEFV_frd_vari));sumEFV_frd_variation(2:2:length(sumEFV_frd_vari))];
sumEFV_frd_variation(2,find(isinf(sumEFV_frd_variation(2,:)))) = 0;
sumEFV_frd_variation(4,find(isinf(sumEFV_frd_variation(4,:)))) = 0;
sumEFV_frd_variation_norm = [sum(sumEFV_frd_variation(2,:).*sumEFV_frd_variation(1,:)/sum(sumEFV_frd_variation(1,:))) sum(sumEFV_frd_variation(4,:).*sumEFV_frd_variation(3,:)/sum(sumEFV_frd_variation(3,:)))];
sumEFV_frd_variation_norm = [sumEFV_frd_variation_norm sqrt(sumEFV_frd_variation_norm(1)^2*sum(sumEFV_frd_variation(1,:))^2/(sum(sumEFV_frd_variation(1,:))^2+sum(sumEFV_frd_variation(3,:))^2)+sumEFV_frd_variation_norm(2)^2*sum(sumEFV_frd_variation(3,:))^2/(sum(sumEFV_frd_variation(1,:))^2+sum(sumEFV_frd_variation(3,:))^2))];
% mixed
sumEFV_mixed_noRC = sum(abs(EFV_coefficient_mixed_noRC(:,:,:)),1);
sumEFV_mixed_noRC = sumEFV_mixed_noRC(1,:);
sumEFV_mixed_RC = sum(abs(EFV_coefficient_mixed_RC(:,:,:)),1);
sumEFV_mixed_RC = sumEFV_mixed_RC(1,:);
sumEFV_mixed_vari = abs((sumEFV_mixed_RC-sumEFV_mixed_noRC));
sumEFV_mixed_variation = sumEFV_mixed_vari./sumEFV_mixed_noRC;
sumEFV_mixed_variation = [sumEFV_mixed_vari(1:2:length(sumEFV_mixed_vari));sumEFV_mixed_variation(1:2:length(sumEFV_mixed_vari));sumEFV_mixed_vari(2:2:length(sumEFV_mixed_vari));sumEFV_mixed_variation(2:2:length(sumEFV_mixed_vari))];
sumEFV_mixed_variation(2,find(isinf(sumEFV_mixed_variation(2,:)))) = 0;
sumEFV_mixed_variation(4,find(isinf(sumEFV_mixed_variation(4,:)))) = 0;
sumEFV_mixed_variation_norm = [sum(sumEFV_mixed_variation(2,:).*sumEFV_mixed_variation(1,:)/sum(sumEFV_mixed_variation(1,:))) sum(sumEFV_mixed_variation(4,:).*sumEFV_mixed_variation(3,:)/sum(sumEFV_mixed_variation(3,:)))];
sumEFV_mixed_variation_norm = [sumEFV_mixed_variation_norm sqrt(sumEFV_mixed_variation_norm(1)^2*sum(sumEFV_mixed_variation(1,:))^2/(sum(sumEFV_mixed_variation(1,:))^2+sum(sumEFV_mixed_variation(3,:))^2)+sumEFV_mixed_variation_norm(2)^2*sum(sumEFV_mixed_variation(3,:))^2/(sum(sumEFV_mixed_variation(1,:))^2+sum(sumEFV_mixed_variation(3,:))^2))];
% noavg
sumEFV_noavg_noRC = sum(abs(EFV_coefficient_noavg_noRC(:,:,:)),1);
sumEFV_noavg_noRC = sumEFV_noavg_noRC(1,:);
sumEFV_noavg_RC = sum(abs(EFV_coefficient_noavg_RC(:,:,:)),1);
sumEFV_noavg_RC = sumEFV_noavg_RC(1,:);
sumEFV_noavg_vari = abs((sumEFV_noavg_RC-sumEFV_noavg_noRC));
sumEFV_noavg_variation = sumEFV_noavg_vari./sumEFV_noavg_noRC;
sumEFV_noavg_variation = [sumEFV_noavg_vari(1:2:length(sumEFV_noavg_vari));sumEFV_noavg_variation(1:2:length(sumEFV_noavg_vari));sumEFV_noavg_vari(2:2:length(sumEFV_noavg_vari));sumEFV_noavg_variation(2:2:length(sumEFV_noavg_vari))];
sumEFV_noavg_variation(:,find(isnan(sumEFV_noavg_variation(2,:)))) = [];
sumEFV_noavg_variation(2,find(isinf(sumEFV_noavg_variation(2,:)))) = 0;
sumEFV_noavg_variation(4,find(isinf(sumEFV_noavg_variation(4,:)))) = 0;
sumEFV_noavg_variation_norm = [sum(sumEFV_noavg_variation(2,:).*sumEFV_noavg_variation(1,:)/sum(sumEFV_noavg_variation(1,:))) sum(sumEFV_noavg_variation(4,:).*sumEFV_noavg_variation(3,:)/sum(sumEFV_noavg_variation(3,:)))];
sumEFV_noavg_variation_norm = [sumEFV_noavg_variation_norm sqrt(sumEFV_noavg_variation_norm(1)^2*sum(sumEFV_noavg_variation(1,:))^2/(sum(sumEFV_noavg_variation(1,:))^2+sum(sumEFV_noavg_variation(3,:))^2)+sumEFV_noavg_variation_norm(2)^2*sum(sumEFV_noavg_variation(3,:))^2/(sum(sumEFV_noavg_variation(1,:))^2+sum(sumEFV_noavg_variation(3,:))^2))];
% smooth
sumEFV_smooth_noRC = sum(abs(EFV_coefficient_smooth_noRC(:,:,:)),1);
sumEFV_smooth_noRC = sumEFV_smooth_noRC(1,:);
sumEFV_smooth_RC = sum(abs(EFV_coefficient_smooth_RC(:,:,:)),1);
sumEFV_smooth_RC = sumEFV_smooth_RC(1,:);
sumEFV_smooth_vari = abs((sumEFV_smooth_RC-sumEFV_smooth_noRC));
sumEFV_smooth_variation = sumEFV_smooth_vari./sumEFV_smooth_noRC;
sumEFV_smooth_variation = [sumEFV_smooth_vari(1:2:length(sumEFV_smooth_vari));sumEFV_smooth_variation(1:2:length(sumEFV_smooth_vari));sumEFV_smooth_vari(2:2:length(sumEFV_smooth_vari));sumEFV_smooth_variation(2:2:length(sumEFV_smooth_vari))];
sumEFV_smooth_variation(:,find(isnan(sumEFV_smooth_variation(2,:)))) = [];
sumEFV_smooth_variation(2,find(isinf(sumEFV_smooth_variation(2,:)))) = 0;
sumEFV_smooth_variation(4,find(isinf(sumEFV_smooth_variation(4,:)))) = 0;
sumEFV_smooth_variation_norm = [sum(sumEFV_smooth_variation(2,:).*sumEFV_smooth_variation(1,:)/sum(sumEFV_smooth_variation(1,:))) sum(sumEFV_smooth_variation(4,:).*sumEFV_smooth_variation(3,:)/sum(sumEFV_smooth_variation(3,:)))];
sumEFV_smooth_variation_norm = [sumEFV_smooth_variation_norm sqrt(sumEFV_smooth_variation_norm(1)^2*sum(sumEFV_smooth_variation(1,:))^2/(sum(sumEFV_smooth_variation(1,:))^2+sum(sumEFV_smooth_variation(3,:))^2)+sumEFV_smooth_variation_norm(2)^2*sum(sumEFV_smooth_variation(3,:))^2/(sum(sumEFV_smooth_variation(1,:))^2+sum(sumEFV_smooth_variation(3,:))^2))];
% noavg_int
sumEFV_noavg_int_noRC = sum(abs(EFV_coefficient_noavg_int_noRC(:,:,:)),1);
sumEFV_noavg_int_noRC = sumEFV_noavg_int_noRC(1,:);
sumEFV_noavg_int_RC = sum(abs(EFV_coefficient_noavg_int_RC(:,:,:)),1);
sumEFV_noavg_int_RC = sumEFV_noavg_int_RC(1,:);
sumEFV_noavg_int_vari = abs((sumEFV_noavg_int_RC-sumEFV_noavg_int_noRC));
sumEFV_noavg_int_variation = sumEFV_noavg_int_vari./sumEFV_noavg_int_noRC;
sumEFV_noavg_int_variation = [sumEFV_noavg_int_vari(1:2:length(sumEFV_noavg_int_vari));sumEFV_noavg_int_variation(1:2:length(sumEFV_noavg_int_vari));sumEFV_noavg_int_vari(2:2:length(sumEFV_noavg_int_vari));sumEFV_noavg_int_variation(2:2:length(sumEFV_noavg_int_vari))];
sumEFV_noavg_int_variation(:,find(isnan(sumEFV_noavg_int_variation(2,:)))) = [];
sumEFV_noavg_int_variation(2,find(isinf(sumEFV_noavg_int_variation(2,:)))) = 0;
sumEFV_noavg_int_variation(4,find(isinf(sumEFV_noavg_int_variation(4,:)))) = 0;
sumEFV_noavg_int_variation(:,find(sumEFV_noavg_int_variation(2,:)>10)) = [];
sumEFV_noavg_int_variation_norm = [sum(sumEFV_noavg_int_variation(2,:).*sumEFV_noavg_int_variation(1,:)/sum(sumEFV_noavg_int_variation(1,:))) sum(sumEFV_noavg_int_variation(4,:).*sumEFV_noavg_int_variation(3,:)/sum(sumEFV_noavg_int_variation(3,:)))];
sumEFV_noavg_int_variation_norm = [sumEFV_noavg_int_variation_norm sqrt(sumEFV_noavg_int_variation_norm(1)^2*sum(sumEFV_noavg_int_variation(1,:))^2/(sum(sumEFV_noavg_int_variation(1,:))^2+sum(sumEFV_noavg_int_variation(3,:))^2)+sumEFV_noavg_int_variation_norm(2)^2*sum(sumEFV_noavg_int_variation(3,:))^2/(sum(sumEFV_noavg_int_variation(1,:))^2+sum(sumEFV_noavg_int_variation(3,:))^2))];
% % smooth_int
sumEFV_smooth_int_noRC = sum(abs(EFV_coefficient_smooth_int_noRC(:,:,:)),1);
sumEFV_smooth_int_noRC = sumEFV_smooth_int_noRC(1,:);
sumEFV_smooth_int_RC = sum(abs(EFV_coefficient_smooth_int_RC(:,:,:)),1);
sumEFV_smooth_int_RC = sumEFV_smooth_int_RC(1,:);
sumEFV_smooth_int_vari = abs((sumEFV_smooth_int_RC-sumEFV_smooth_int_noRC));
sumEFV_smooth_int_variation = sumEFV_smooth_int_vari./sumEFV_smooth_int_noRC;
sumEFV_smooth_int_variation = [sumEFV_smooth_int_vari(1:2:length(sumEFV_smooth_int_vari));sumEFV_smooth_int_variation(1:2:length(sumEFV_smooth_int_vari));sumEFV_smooth_int_vari(2:2:length(sumEFV_smooth_int_vari));sumEFV_smooth_int_variation(2:2:length(sumEFV_smooth_int_vari))];
sumEFV_smooth_int_variation(:,find(isnan(sumEFV_smooth_int_variation(2,:)))) = [];
sumEFV_smooth_int_variation(2,find(isinf(sumEFV_smooth_int_variation(2,:)))) = 0;
sumEFV_smooth_int_variation(4,find(isinf(sumEFV_smooth_int_variation(4,:)))) = 0;
sumEFV_smooth_int_variation(:,find(sumEFV_smooth_int_variation(2,:)>10)) = [];
sumEFV_smooth_int_variation_norm = [sum(sumEFV_smooth_int_variation(2,:).*sumEFV_smooth_int_variation(1,:)/sum(sumEFV_smooth_int_variation(1,:))) sum(sumEFV_smooth_int_variation(4,:).*sumEFV_smooth_int_variation(3,:)/sum(sumEFV_smooth_int_variation(3,:)))];
sumEFV_smooth_int_variation_norm = [sumEFV_smooth_int_variation_norm sqrt(sumEFV_smooth_int_variation_norm(1)^2*sum(sumEFV_smooth_int_variation(1,:))^2/(sum(sumEFV_smooth_int_variation(1,:))^2+sum(sumEFV_smooth_int_variation(3,:))^2)+sumEFV_smooth_int_variation_norm(2)^2*sum(sumEFV_smooth_int_variation(3,:))^2/(sum(sumEFV_smooth_int_variation(1,:))^2+sum(sumEFV_smooth_int_variation(3,:))^2))];
