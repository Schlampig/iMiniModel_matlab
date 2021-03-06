function UMultiV_MHKS_main(file_name,datanum,ktimes,ratio,C,zet,gama,uscale)

%注意：超出范围的设置没有报错机制。
%ktimes：MCCV迭代次数（1,2,3,...,10）
%ratio：训练数量比（0.1,0.2,0.3,...,0.9）
%gama：松弛因子1
%C:松弛因子2
%zet：控制正则项的惩罚因子
%scale：控制Universum样本规模的因子
%M_row：矩阵化的行数
%M_col：矩阵化的列数

switch datanum %根据数据集标号选择数据集
    case 0
        load breast_cancer_wisconsin_all.mat;
        dataname = 'breast_cancer_wisconsin'; 
        M_row = [1;2];%人工设定行列数，M=2
        M_col = [10;5];
    case 1
        load iris_all.mat;
        dataname = 'iris';
        M_row = [1;2];
        M_col = [4;2];
    case 2
        load cmc_all.mat;
        dataname = 'cmc';
        M_row = [1;3];
        M_col = [9;3];
    case 3
        load sonar_all.mat;
        dataname = 'sonar';
        M_row = [3;4];
        M_col = [20;15];
    case 4
        load lenses_all.mat;
        dataname = 'lenses';
        M_row = [1;2];
        M_col = [4;2];
    case 5
        load glass_all_new.mat;
        dataname = 'glass';
        M_row = [1;3];
        M_col = [9;3];
    case 6
        load water_all.mat;
        dataname = 'water';
        M_row = [1;2];
        M_col = [38;19];
    case 7
        load horse_colic_all.mat;
        dataname = 'horse_colic';
        M_row = [1;3];
        M_col = [27;9];
    case 8
        load transfusion_all.mat;
        dataname = 'transfusion';
        M_row = [1;2];
        M_col = [4;2];
    case 9
        load secom_all.mat;
        dataname = 'secom';
        M_row = [2;10];
        M_col = [295;59];
    case 10
        load house_votes_all.mat;
        dataname = 'house_votes';
        M_row = [2;4];
        M_col = [8;4];
    case 11
        load housing_all.mat;
        dataname = 'housing';
        M_row = [2;3];
        M_col = [6;4];
    case 12
        load ionosphere_all.mat;
        dataname = 'ionosphere';
        M_row = [1;2];
        M_col = [34;17];
    case 13
        load Repair_pima_all.mat;
        dataname = 'Repair_pima';
        M_row = [1;2];
        M_col = [8;4];
    otherwise
        disp('You have input wrong dataset number!');%报错 
end%end_switch_dataset_kind

file_id = fopen(file_name, 'w');

fprintf(file_id, 'Setting: MCCV_Time-%.4f ,Training_Ratio(Beta)-%.1f ,Gama-%.3f,C-%.3f ,Zeta-%.3f ,Universum_scale-%.1f,Dataset-%s \r\n', ktimes,ratio,gama,C,zet,uscale,dataname);
disp(['Setting: MCCV_Time-',num2str(ktimes),', Training_Ratio(Beta)-',num2str(ratio),', Gama-',num2str(gama),' ,C-',num2str(C),' ,Zeta-',num2str(zet),' ,Universum_scale-',num2str(uscale),' ,Dataset-',dataname]);%打印在屏幕上
time = zeros(ktimes,1);%设立记录训练时间的向量

%计算类偏移量，第i类的偏移记录在bias_class(i)里
bias_class = zeros(length(unique(label)),1);
for i_label = 1:length(unique(label))
    i_label_tempt = find(label==unique(i_label));
    bias_class(i_label) = i_label_tempt(1);
end%for_i_label
bias_class = bias_class - 1;

sum_class = numel(unique(label));%求类总数

accuracy = zeros(ktimes,1);%记录精确度的向量

for i_iter = 1:ktimes%第i_iter轮MCCV
    %类两两训练
 tic;%开始计算一次迭代的训练时间
    for i_classone = 1:(sum_class-1)
        for i_classtwo = (i_classone+1):sum_class
            
            sum_classone_sample = length(find(label==i_classone));%找出当前两类各自的样本数
            sum_classtwo_sample = length(find(label==i_classtwo));          
            train_classone_sample = round(sum_classone_sample*ratio);%四舍五入取整找出训练样本数
            train_classtwo_sample = round(sum_classtwo_sample*ratio);
            bias_classone = bias_class(i_classone);%获取当前类的偏移量
            bias_classtwo = bias_class(i_classtwo);
              
            train_classone_data = data(:,index_struct(i_iter,i_classone).index(1:train_classone_sample)+bias_classone);%设置训练样本
            train_classtwo_data = data(:,index_struct(i_iter,i_classtwo).index(1:train_classtwo_sample)+bias_classtwo);
            train_binary_data = [train_classone_data,train_classtwo_data]';
            train_classone_label = ones(train_classone_sample,1)*i_classone;%设置训练样本类标号
            train_classtwo_label = ones(train_classtwo_sample,1)*i_classtwo;
            train_binary_label = [train_classone_label;train_classtwo_label];
           
            %第i_iter次MCCV迭代，第i_classone类和第i_classtwo类参与训练后得到的UMultiV-MHKS数据存入UMultiVStruct(i_classone,i_classtwo).candidate内
            UMultiVStruct(i_classone,i_classtwo).candidate = UMultiV_MHKS_fun(train_binary_data,train_binary_label,C,zet,gama,uscale,M_row,M_col);%代入训练
            
            %清空
            clear sum_classone_sample;clear sum_classtwo_sample;
            clear train_classone_sample;clear train_classtwo_sample;
            clear bias_classone;clear bias_classtwo;
            clear train_classone_data;clear train_classtwo_data;clear train_binary_data;
            clear train_classone_label;clear train_classtwo_label;clear train_binary_label;

        end%for_i_classtwo
    end%for_i_classone  
 time(ktimes) = toc;%第ktimes次MCCV训练用时
    
    %测试
    %生成测试样本数据集test_data和对应的类标号test_label
    sum_classtempt_sample = length(find(label==1));
    test_classtempt_sample = sum_classtempt_sample - round(sum_classtempt_sample*ratio);
    test_data = data(:,index_struct(i_iter,1).index((sum_classtempt_sample-test_classtempt_sample+1):sum_classtempt_sample));
    test_label = 1*ones(test_classtempt_sample,1);
    clear sum_classtempt_sample; clear test_classtempt_sample;
    for i_test = 2:sum_class
        bias_classtempt = bias_class(i_test);%获取当前类的偏移量
        sum_classtempt_sample = length(find(label==i_test));
        test_classtempt_sample = sum_classtempt_sample - round(sum_classtempt_sample*ratio);
        test_data = cat(2,test_data,data(:,index_struct(i_iter,i_test).index((sum_classtempt_sample-test_classtempt_sample+1):sum_classtempt_sample)+bias_classtempt));
        test_label = cat(1,test_label,i_test*ones(test_classtempt_sample,1));
    end%for_i_test
    test_data_final = (test_data)';
    
    matrix_vote = zeros(length(test_label),1);%设置投票矩阵，每一列是一个Group候选，第1列是总票数统计
    for i_testone = 1:(sum_class-1)
        for i_testtwo = (i_testone+1):sum_class
            %依次代入两两类训练获得的数据进行测试          
            Group = UMultiV_MHKS_test(UMultiVStruct(i_testone,i_testtwo).candidate,test_data_final,i_testone,i_testtwo,M_row,M_col);
            matrix_vote = cat(2,matrix_vote,Group);%加入候补
            clear Group;
        end%for_i_testtwo
    end%for_i_testone 

    i_candidate = (sum_class)*(sum_class-1)/2;
    for i_poll = 1:length(test_label)
        vector_vote = matrix_vote(i_poll,2:(i_candidate+1));
        matrix_vote(i_poll,1) = mode(vector_vote);
    end%for_i_poll
    
    accuracy(i_iter) = 100*(1-(length(find((test_label - matrix_vote(:,1))~=0))/length(test_label)));
    
    fprintf(file_id,'The present accuracy of %d iteration in MCCV is: %f; \r\n',i_iter,accuracy(i_iter));
    disp(['The present accuracy of ',num2str(i_iter),' iteration in MCCV is: ',num2str(accuracy(i_iter))]);%打印在屏幕上
end%for_i_iter

    fprintf(file_id,'The average accuracy is: %f; \r\n',mean(accuracy));%ktimes轮均值
    disp(['The average accuracy is: ',num2str(mean(accuracy))]);%打印在屏幕上
    fprintf(file_id,'The std of accuracies is: %f; \r\n',std(accuracy));%ktimes轮均方差
    disp(['The std of accuracies is: ',num2str(std(accuracy))]);
    fprintf(file_id,'The average time(s) is: %f; \r\n',mean(time));%ktimes轮时间
    disp(['The average time(s) is: ',num2str(mean(time))]);
    fclose(file_id);%关闭文件
    
clear;