function stego_info = OPA_stego(in_path,message,key,out_path)
%α��ͼ�� OPA��д�㷨
%in_path: ����ͼ��·��
%message: ������Ϣ sting
%key: ������Կ int
%out_path: ��д��ͼ�񱣴�·�� 

%��ȡα��ͼ����Ϣ ��������ɫ��
[img_data, map] =imread(in_path);
[color_number,~]=size(map);

%��д��Ϣת������
native=unicode2native(message);			%ת�ɱ��ر���
msgBin=de2bi(native,8,'left-msb');		%�ֽ�ת��8bit
%������Ϣͷ����Ϣ��ȫ����С��������д��Ϣ����дͷ��
len = size(msgBin,1).*size(msgBin,2);  %������д��Ϣ��С
sum_len = int32(len+32);
head_data = de2bi(sum_len, 32, 'left-msb');
%����������Ϣ
mes_bin = reshape(double(msgBin).',len,1).';
mes_bin = [head_data,mes_bin];

%1 ������ɫ��ż����
color_dis = zeros(color_number*(color_number-1)/2, 3);  %1������ 2��3:��ɫ����
temp_map = map;  %������ɫ��
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

%�������������д
[~,wid1]=size(img_data);
m = 1;
n = key;
img_data = img_data + 1;  %matlab������1��ʼ����ɫ������0��ʼ��������������
for i = 1:length(mes_bin)
    if n>wid1
        m= m+floor(n/wid1);
        n=mod(n,wid1);
    end
    %����Ҫ���ܵ���Ϣ��ԭʼ��Ϣ��ż��ͬ�����ڱ����ҳ���Ӧ��ɫ
    if map(img_data(m,n),4) ~=mes_bin(i)
        for j= 1:length(color_dis)
            if color_dis(j,2) ==img_data(m,n)||color_dis(j,3) ==img_data(m,n)
                %ѡȡ��������ɫ�������ɫ��  
                if map(color_dis(j,2),4) == mes_bin(i)
                    img_data(m,n) = color_dis(j,2) ;
                    break;
                elseif map(color_dis(j,3),4) == mes_bin(i)
                    img_data(m,n) = color_dis(j,3) ;
                      break;
                end
            end
        end
    end
    n = n+1;
end
img_data = img_data - 1;  %matlab������1��ʼ��������������
imwrite(img_data, temp_map,out_path);
stego_info = sprintf('message stego to %s',out_path);
end

