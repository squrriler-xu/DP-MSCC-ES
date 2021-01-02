unction [species, meandis]= NBC(matdis, nich_max, dim)
%NBC 此处显示有关此函数的摘要
%   此处显示详细说明
factor=2; % fai
n=length(matdis); % 边
nbc=zeros(n,3); % 信息矩阵，起始点，终止点，距离
nbc(1:n,1)=1:n;
nbc(1,2)=-1;
nbc(1,3)=0;
for i=2:n
    [u,v]=min(matdis(i,1:i-1)); % u记录最小值，v记录对应的索引
    nbc(i,2)=v;
    nbc(i,3)=u;
end
meandis=factor*mean(nbc(2:n,3));
if meandis > power(1e-6, 1/dim)
    nbc(nbc(:,3)>meandis,2)=-1;
    nbc(nbc(:,3)>meandis,3)=0;
end

seeds=nbc(nbc(:,2)==-1,1);
m=zeros(n,2); % 保存各个粒子索引以及对应的簇号
m(1:n,1)=1:n;
for i=1:n
    j=nbc(i,2);
    k=j;
    while j~=-1
        k=j;
        j=nbc(j,2);
    end
    if k==-1
        m(i,2)=i;
    else
        m(i,2)=k;
    end
end % 此时每个粒子对应的是该粒子所在簇的seed编号
% count=1;
% for i=1:length(seeds)
%     j=seeds(i);
%     m(m(:,2)==j,2)=count;
%     count=count+1; % 把seed编号转化为簇号
% end

% construct the result
    species = struct();
    num_species = length(seeds);
    
    if num_species > nich_max
        seeds = seeds(1:nich_max);
    end
    for i=1:length(seeds)
       species(i).seed = seeds(i);
       species(i).idx = m(m(:, 2) == seeds(i), 1);
       species(i).len = length(species(i).idx);
    end

end

