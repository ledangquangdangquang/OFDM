function B_pilot = pilot(B, K, Df, Dt)
lenB = numel(B);      % = 8
B_pilot = zeros(K, 1);      % khởi tạo 1 cột trước
t = 1;
while true
    % ---- chèn pilot (giữ nguyên logic) ----
    B_pilot(1:Df:K, t) = 1 + 0j;
    % ---- đếm số 0 ----
    count0 = sum(B_pilot(:) == 0);
    if count0 == lenB
        break
    end
    % ---- thêm symbol mới ----
    B_pilot(:, t+1) = 0;
    t = t + Dt;
end
% ===== PHẦN MỚI: thay 0 bằng B =====
z = find(B_pilot == 0);
B_pilot(z(1:lenB)) = B(:);
end
