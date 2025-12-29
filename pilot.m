function B_pilot = pilot(B, K, Df, Dt)
lenB = numel(B);      % = 8
B_pilot = zeros(K, 1);      % khởi tạo 1 cột trước
count =  1;
while true
    for i = 1:Df:K
        B_pilot(i,count) = 1;
    end
    count0 = sum(B_pilot(:) == 0);
    if count0 == lenB
        break
    end
    for k = 1:Dt-1
        B_pilot(:, k+count) = 0;
    end
    count = count + Dt;
    count0 = sum(B_pilot(:) == 0);
    if count0 == lenB
        break
    end
    % Bảo vệ: Tránh vòng lặp vô hạn nếu max_cols tính toán sai
    if count > 1000 % Ngưỡng an toàn
        disp('Nên chọn lại K, Df, Dt');
        break;
    end
end
% disp(B_pilot);

pilot_matrix = B_pilot;
save('pilot_matrix','pilot_matrix') ;
% ===== PHẦN MỚI: thay 0 bằng B =====
z = find(B_pilot == 0);
B_pilot(z(1:lenB)) = B(:);
end
