function BEPILD_main(dataset_name, data_index,ktimes,dp_index,num_reg)

%��׼BEPILDģ�ͣ���������ѡ�񣬼��߽��ж�

% dataset_name�� ������ݼ��ļ��ϵ�����
% data_index�� ���ݼ����
% ktimes: ����������һ��Ϊ5��10�֣��������ݼ�������
% dp_index:����ѡ�����ɵ�dp������label��ֵ������dp_Gernerate()
% num_reg: ����Ȩ�ز����������� reg=0�������Ŷ���regԽ���Ŷ�Խ��

% Ԥ����
load(dataset_name);
dataname =  strcat('BEPILD_',Imbalanced_data{data_index,1},'_dp',num2str(dp_index),'_reg',num2str(num_reg));%ת����ļ���
final_res = zeros(ktimes+2,8);%��¼ktimes�ֽ���ľ���,�����ڶ��д��ֵ�����һ�д�std��ÿһ�зֱ���TP,FP,TN,FN,acc,��ֵacc��gm,auc=

% ѵ�������
for i_cv = 1:ktimes
   % ������ݼ�
   train_all = Imbalanced_data{data_index,3}{i_cv,1};
   test_all = Imbalanced_data{data_index,3}{i_cv,2}; 
   % ѵ��
   [model,flag] = BEPILD_train(train_all,dp_index,num_reg);
   % ����
   if flag == 1 % �ɷ����Σ�����Ҫʹ������ʽ�㷨
       [vec_res] = PILD_test(test_all,model);
   elseif flag == 0 %�ص����Σ���Ҫʹ������ʽ�㷨
       [vec_res] = BEPILD_test(test_all,model);
   end%if
   %ͳ��һ�ֵĽ��
   final_res(i_cv,:) = vec_res;    
end%for_i_cv

% ͳ�ƽ��
final_res(ktimes+1,:) = mean(final_res(1:ktimes,:));
final_res(ktimes+2,:) = std(final_res(1:ktimes,:));

% ������
save([dataname,'.mat'],'final_res');


end