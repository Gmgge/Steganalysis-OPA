function stego_info = OPA_stego(in_path,message,key,out_path)
%伪彩图像 OPA隐写算法
%in_path: 输入图像路径
%message: 加密信息 sting
%key: 简易密钥 int
%out_path: 隐写后图像保存路径 

%读取伪彩图像信息 索引表、颜色表
[img_data, map] =imread(in_path);
[color_number,~]=size(map);

%隐写消息转二进制
native=unicode2native(message);			%转成本地编码
msgBin=de2bi(native,8,'left-msb');		%字节转成8bit
%计算消息头：消息的全部大小（包含隐写消息与隐写头）
len = size(msgBin,1).*size(msgBin,2);  %计算隐写消息大小
sum_len = int32(len+32);
head_data = de2bi(sum_len, 32, 'left-msb');
%构建完整消息
mes_bin = reshape(double(msgBin).',len,1).';
mes_bin = [head_data,mes_bin];

%1 计算颜色奇偶属性
color_dis = zeros(color_number*(color_number-1)/2, 3);  %1：距离 2，3:颜色索引
temp_map = map;  %备份颜色表
%1.1 计算颜色距离并排序
dis_index = 1;
for m = 1:color_number 
    for n = m+1:color_number
        color_dis(dis_index, :) = [sqrt((map(m,1)-map(n,1))^2+(map(m,2)-map(n,2))^2+(map(m,3)-map(n,3))^2),m,n];
        dis_index = dis_index + 1;
    end
end
color_dis = sortrows(color_dis,1);
%1.2 根据距离给map中的颜色分配奇偶属性
map(:,4)=2; %初始化奇偶分配 2表示未分配奇偶属性
num = color_number * (color_number-1) / 2;
for n = 1:num
    %如果两个颜色都未分配奇偶属性，则取第一个为奇，第二个为偶
    if map(color_dis(n,2),4)==2 && map(color_dis(n,3),4)==2
        map(color_dis(n,2),4)=1;
        map(color_dis(n,3),4)=0;
    %如果两个颜色都分配，则继续下一循环
    elseif map(color_dis(n,2),4)~=2 && map(color_dis(n,3),4)~=2
        continue
    %如果第一个已分配属性，第二个未分配，则第二个属性取反
    elseif map(color_dis(n,2),4)~=2
        map(color_dis(n,3),4)= 1-map(color_dis(n,2),4);
    %如果第二个已分配属性，第一个未分配，则第一个属性取反
    elseif map(color_dis(n,3),4)~=2
        map(color_dis(n,2),4)= 1-map(color_dis(n,3),4);
    end
end 

%对索引表进行隐写
[~,wid1]=size(img_data);
m = 1;
n = key;
img_data = img_data + 1;  %matlab索引从1开始，颜色索引从0开始，进行索引换算
for i = 1:length(mes_bin)
    if n>wid1
        m= m+floor(n/wid1);
        n=mod(n,wid1);
    end
    %假如要加密的消息与原始信息奇偶不同，则在表中找出对应颜色
    if map(img_data(m,n),4) ~=mes_bin(i)
        for j= 1:length(color_dis)
            if color_dis(j,2) ==img_data(m,n)||color_dis(j,3) ==img_data(m,n)
                %选取包含该颜色的最近颜色对  
                if map(color_dis(j,2),4) == mes_bin(i)
                    img_data(m,n) = color_dis(j,2);
                    break;
                elseif map(color_dis(j,3),4) == mes_bin(i)
                    img_data(m,n) = color_dis(j,3);
                      break;
                end
            end
        end
    end
    n = n+1;
end
img_data = img_data - 1;  %matlab索引从1开始，进行索引换算
imwrite(img_data, temp_map,out_path);
stego_info = sprintf('message stego to %s',out_path);
end

