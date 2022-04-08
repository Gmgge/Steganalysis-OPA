function message = OPA_extract(img_path, key)
%OPA��д����Ϣ��ȡ�㷨
%img_path: �ļ�·��
%key: ������Կ

%��ȡα��ͼ�� ����������ɫmap
[img_data, map] =imread(img_path);
[color_number,~]=size(map);

%1 ������ɫ��ż����
color_dis = zeros(color_number*(color_number-1)/2, 3);  %1������ 2��3:��ɫ����
%1.1 ������ɫ���벢����
dis_index = 1;
for m = 1:color_number 
    for n = m+1:color_number
        color_dis(dis_index, :) = [sqrt((map(m,1)-map(n,1))^2+(map(m,2)-map(n,2))^2+(map(m,3)-map(n,3))^2),m,n];
        dis_index = dis_index + 1;
    end
end
color_dis = sortrows(color_dis,1);
%1.2 ���ݾ����map�е���ɫ������ż����
map(:,4)=2; %��ʼ����ż���� 2��ʾδ������ż����
num = color_number * (color_number-1) / 2;
for n = 1:num
    %���������ɫ��δ������ż���ԣ���ȡ��һ��Ϊ�棬�ڶ���Ϊż
    if map(color_dis(n,2),4)==2 && map(color_dis(n,3),4)==2
        map(color_dis(n,2),4)=1;
        map(color_dis(n,3),4)=0;
    %���������ɫ�����䣬�������һѭ��
    elseif map(color_dis(n,2),4)~=2 && map(color_dis(n,3),4)~=2
        continue
    %�����һ���ѷ������ԣ��ڶ���δ���䣬��ڶ�������ȡ��
    elseif map(color_dis(n,2),4)~=2
        map(color_dis(n,3),4)= 1-map(color_dis(n,2),4);
    %����ڶ����ѷ������ԣ���һ��δ���䣬���һ������ȡ��
    elseif map(color_dis(n,3),4)~=2
        map(color_dis(n,2),4)= 1-map(color_dis(n,3),4);
    end
end 

[~,img_w]=size(img_data);
m = 1;
n = key;
img_data = img_data + 1;  %matlab������1��ʼ��������������
%��ȡ��д��Ϣͷ�ļ�
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
%��ȡ��������д��Ϣ
mes_bin = [];
for i = 33:mes_len
    if n>img_w
        m= m+floor(n/img_w);
        n=mod(n,img_w);
    end
    mes_bin = [mes_bin,num2str(map(img_data(m,n),4))];
    n = n+1;
end
%ת���ɱ��ر���
bin_len = length(mes_bin);
mes_native = zeros(1,bin_len/8);
for k = 1:length(mes_native)
    temp_bin = mes_bin(((k-1)*8+1:k*8));
    mes_native(k) = bin2dec(temp_bin);
end
%ת��Ϊunicode������ַ���
message = native2unicode(mes_native);
end

