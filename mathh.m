% 初始化19x19的矩阵
distance_matrix =  zeros(19, 19);  % 距离矩阵
lights_matrix = zeros(19, 19);    % 红绿灯矩阵
a_matrix = zeros(19, 19);         % 绿色通道占比 1
b_matrix = zeros(19, 19);         % 黄色通道占比 2
c_matrix = zeros(19, 19);         % 红色通道占比 3
v_matrix =  ones(19, 19);         % 正常时速矩阵

% 给定的连线信息：每个元素为 (起点, 终点, 距离, 灯)
connections = [
    1, 2, 1.2, 3; 1, 4, 5.6, 7; 2, 3, 0.893, 0; 2, 12, 12.6, 7;
    3, 13, 9.8, 4; 4, 5, 4.5, 5; 4, 12, 7.9, 0; 5, 6, 2.8, 0;
    5, 7, 1.1, 0; 6, 8, 2.4, 0; 7, 8, 2.4, 0; 7, 9, 3.3, 0;
    8, 10, 3.1, 0; 9, 11, 1.8, 0; 10, 11, 1.5, 0; 10, 16, 1.4, 0;
    11, 12, 2.0, 0; 11, 17, 3.4, 0; 12, 14, 3.2, 0; 12, 15, 1.7, 0;
    13, 14, 0.9, 0; 14, 15, 4.1, 6; 14, 18, 6.4, 4; 15, 16, 3.9, 0;
    15, 17, 3.5, 1; 15, 18, 3.3, 0; 16, 17, 3.6, 8; 17, 19, 3.1, 0;
    17, 18, 5.2, 0; 18, 19, 2.4, 0
];

% 填充距离和红绿灯矩阵
for i = 1:size(connections, 1)
    start = connections(i, 1);
    end_ = connections(i, 2);
    dist = connections(i, 3);
    lights = connections(i, 4);

    distance_matrix(start, end_) = dist;
    distance_matrix(end_, start) = dist;  % 因为是双向的

    lights_matrix(start, end_) = lights;
    lights_matrix(end_, start) = lights;
end

% 给定的连接信息：每个元素为 (起点, 终点, 各通道占比, 正常时速)
connections_info = [
    1, 2, [1, 0, 0], 70; 1, 4, [1, 0, 0], 70; 2, 3, [1, 0, 0], 70; 2, 12, [0.7, 0.3, 0], 70;
    3, 13, [1, 0, 0], 90; 4, 5, [1, 0, 0], 70; 4, 12, [1, 0, 0], 90; 5, 6, [1, 0, 0], 70;
    5, 7, [1, 0, 0], 70; 6, 8, [1, 0, 0], 90; 7, 8, [1, 0, 0], 70; 7, 9, [1, 0, 0], 90;
    8, 10, [0.75, 0.20, 0.05], 90; 9, 11, [1, 0, 0], 90; 10, 11, [0.05, 0.80, 0.15], 90;
    10, 16, [1, 0, 0], 90; 11, 12, [1, 0, 0], 90; 11, 17, [1, 0, 0], 90; 12, 14, [1, 0, 0], 90;
    12, 15, [1, 0, 0], 70; 13, 14, [1, 0, 0], 70; 14, 15, [1, 0, 0], 70; 14, 18, [1, 0, 0], 70;
    15, 16, [1, 0, 0], 70; 15, 17, [1, 0, 0], 70; 15, 18, [0.90, 0, 0.1], 70; 16, 17, [1, 0, 0], 70;
    17, 19, [1, 0, 0], 90; 17, 18, [1, 0, 0], 70; 18, 19, [1, 0, 0], 70
];

% 填充矩阵
for i = 1:size(connections_info, 1)
    start = connections_info(i, 1);
    end_ = connections_info(i, 2);
    crowd1 = connections_info(i, 3);
    crowd2 = connections_info(i, 4);
    crowd3 = connections_info(i, 5);
    speed = connections_info(i, 6);

    a_matrix(start, end_) = crowd1;
    a_matrix(end_, start) = crowd1;  % 因为是双向的

    b_matrix(start, end_) = crowd2;
    b_matrix(end_, start) = crowd2;

    c_matrix(start, end_) = crowd3;
    c_matrix(end_, start) = crowd3;

    v_matrix(start, end_) = speed;
    v_matrix(end_, start) = speed;
end

k1 = 1.2;
k2 = 3;
k3 = 10;
lights_ave_time = 51.42;%每个红灯的等待时间
t = 9999 * ones(19,19);
for i = 1:size(distance_matrix, 1)
    for j = 1: size(distance_matrix, 2)
        if distance_matrix(i,j) ~= 0
            t(i,j) = (a_matrix(i,j) * distance_matrix(i,j) * k1 / v_matrix(i,j) + ...
                     b_matrix(i,j) * distance_matrix(i,j) * k2 / v_matrix(i,j) + ...
                     c_matrix(i,j) * distance_matrix(i,j) * k3 / v_matrix(i,j)) * 3600 + ...
                     lights_ave_time * lights_matrix(i,j); 
        else
            t(i,j) = 9999;
        end
    end
end
% t= (a_matrix .* distance_matrix * k1 / v_matrix  ...
% + b_matrix .* distance_matrix * k2 / v_matrix ...
% + c_matrix .* distance_matrix * k3 / v_matrix) ...
% + lights_ave_time * lights_matrix;
disp(t);
numVertices = size(t, 1);
for i=1:numVertices
    for j=1:numVertices
        if i==j 
            t(i,j)=0;
        end
    end
end
disp(t);
G = digraph(t);

[p,d]=shortestpath(G,1,19);
disp(p);%最短路径的途经节点
display(d/60);%最短路径的值，以分钟为单位


