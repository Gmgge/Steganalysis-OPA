function message = OPA_extract(img_path, key)
%OPA隐写的信息提取算法
%img_path: 文件路径
%key: 解密密钥

%读取伪彩图像 索引表与颜色map
[img_data, map] =imread(img_path);
[color_number,~]=size(map);

%1 计算颜色奇偶属性
color_dis = zeros(color_number*(color_number-1)/2, 3);  %1：距离 2，3:颜色索引
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

[~,img_w]=size(img_data);
m = 1;
n = key;
img_data = img_data + 1;  %matlab索引从1开始，进行索引换算
%读取隐写消息头文件
mes_len_bin = [];
for i = 1:32
    if n>img_w
        m= m+floor(n/img_w);
        n=mod(n,img_w);
    end
    mes_len_bin = [mes_len_bin, num2str(map(img_data(m,n),4))];
    n = n+1;
end
mes_len = bin2dec(mes_len_bin);
%读取二进制隐写消息
mes_bin = [];
for i = 33:mes_len
    if n>img_w
        m= m+floor(n/img_w);
        n=mod(n,img_w);
    end
    mes_bin = [mes_bin,num2str(map(img_data(m,n),4))];
    n = n+1;
end
%转换成本地编码
bin_len = length(mes_bin);
mes_native = zeros(1,bin_len/8);
for k = 1:length(mes_native)
    temp_bin = mes_bin(((k-1)*8+1:k*8));
    mes_native(k) = bin2dec(temp_bin);
end
%转换为unicode编码的字符串
message = native2unicode(mes_native);
end

