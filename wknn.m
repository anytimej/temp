% weighted k nearest neighbor 
% apply wknn the data not correctly classified by knn, in the previous step. 
% refer to the article for details.

function [weightresult] = wknn(class_results, knn_idx, position, trainingdata, testdata, inputdata)

% class_results: class label assigned correctly
% knn_idx: k th label in one feature, k=1-11
% position: k th featrue label in one test data, k=1-17
% trainingdata: features of training data
% testdata: features of test data
% inputdata: choose the data which are not assigned correctly by knn

weight_cal(1 : featurenumber, 1) = 0.00001; % The featurenumber is the number selected from all the features.
weight(1 : featurenumber, 1) = 0.00001;

for i = 1 : datanumber % total data
    if( class_results(i) == true)  % class assigned correctly        
        temp = testdata(i, :); % test data features             
        weight_cal(1 : featurenumber, 1) = 0.00001;

        for j = 1 : featurenumber 
            if(position(j)~=1) % k th feature label in one test data is not assigned correctly 
                test_temp = temp(j, :);                              
                %%% weight calculation 
                for k = 1 : 11 % k number
                    k_th_value = knn_idx(j, 11);
                    i_th_value = knn_idx(j, k);
                    first_num = knn_idx(j, 1);                   
                    first_d = sqrt(test_temp(1, 1) - trainingdata(k_th_value, 1) )^2;
                    second_d = sqrt(test_temp(1, 1) - trainingdata(i_th_value, 1) )^2;
                    third_d = sqrt(test_temp(1, 1) - trainingdata(first_num, 1) )^2;                            
                    weight_cal(i_th_value, 1) = ( (first_d - second_d) / (first_d - third_d) )  *  ( (first_d + third_d) / (first_d + second_d) );                     
                end                               
                for k = 1 :11 % k number
                    i_th_value = knn_idx(j, k);
                    if(knn_idx(j, k) <= featurenumber) % add more weight, if assigned correctly 
                        weight(i_th_value, 1) = weight(i_th_value, 1) + weight_cal(i_th_value, 1) + weight_cal(i_th_value, 1)^2;                              
                    else 
                        weight(i_th_value, 1) = weight(i_th_value, 1) + weight_cal(i_th_value, 1);
                    end 
                end   
            end
        end           
    end
end

% classification with weight 
for i = 1 : data_number  % data number for test
    % If necessary for sort
    temp = class_label(i, :)'; % class_label sort
    [c1, c2] = sort(temp, 1, 'ascend');        
    weighting = zeros;    
    for k = 1 : classnumber         
        temp_size = c1(k, 1);
        training( featurenumber * (k-1) + 1 : k * featurenumber, 1: 1) = trainingdata( (temp_size-1) * featurenumber + 1 : temp_size * featurenumber,  1: 1); 
        weighting( featurenumber * (k-1) + 1 : k * featurenumber, 1) = weight( (temp_size-1) * featurenumber + 1 : temp_size * featurenumber, 1);
    end
      
    test = inputdata(i, :); % test data with not assigned correctly              
    [idx, dis] = knnsearch(training, test, 'k', 11);  % knn 
    [a, b] = size(idx);
    re_idx(1 : a, 1 : b) = idx;
    re_dis(1 : a, 1 : b) = dis;

% result of weight 
for j = 1 : feature_number 
        first = 0;
        second = 0;
        third = 0;       
        for k = 1 : 11 
            if( re_idx(j, k) <=featurenumber) % sum weight by class
               first = first + weighting(re_idx(j, k), 1);% classe range  
            elseif(featurenumber < re_idx(j, k) && re_idx(j, k)<=featurenumber*2) 
                second = second + weighting(re_idx(j, k), 1);
            elseif(featurenumber*2 < re_idx(j, k) && re_idx(j, k)<=featurenumber*3) 
                third = third + weighting(re_idx(j, k), 1);          
            end
        end
        weight_knn(j, 1)=first;
        weight_knn(j, 2)=second;
        weight_knn(j, 3)=third;      
end

% choose class with the most large weight among candidate classes 
max_value = 0;
    for j = 1 : featurenumber          
        for k = 1 : 3
            if(max_value< weight_knn(j, k) )
                max_value = weight_knn(j, k);
                max_index = k;
            end
        end
        positionresult(j, 1) = max_value;
        positionresult(j, 2) = max_index;
        max_value=0;
    end    

first = 0; second=0; third =0; 
    for j= 1 : featurenumber 
        if(1 == positionresult(j, 2))
            first = first + 1;
        elseif(2 == positionresult(j, 2))
            second = second + 1;
        elseif(3 == positionresult(j, 2))
            third = third +1;      
        end
    end
    temp_value = first;
    temp_index = c1(1, 1); 
    if(first < second)
        temp_value = second;
        temp_index = c1(2, 1); 
    end
    if(temp_value < third)
        temp_value = third;
        temp_index = c1(3, 1); 
    end    
    result(i, 1) = temp_value;
    result(i, 2) = temp_index;

    if(result(i, 2) == 1)
        first_correct = first_correct + 1;
    elseif(result(i, 2) == 2)
        second_correct = second_correct + 1;
    elseif(result(i, 2) == 3)
        third_correct = third_correct + 1;   
    elseif(result(i, 2) == 4)
        fourth_correct = fourth_correct + 1;   
    end    
    weightresult(1, 1) = first_correct;
    weightresult(2, 1) = second_correct;
    weightresult(3, 1) = third_correct;
    weightresult(4, 1) = fourth_correct;
end
end