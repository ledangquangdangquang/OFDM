function P = S2P(S, m, n)
% S2P: Chuyển đổi dữ liệu từ chuỗi nối tiếp (Serial) sang song song (Parallel)
% 
% Cú pháp: P = S2P(S, m, n)
%
% Giải thích tham số:
%   S : Vector chứa chuỗi bit dữ liệu đầu vào (Serial input).
%   m : Số lượng bit được nhóm lại cho mỗi ký hiệu (Symbol) trên một kênh.
%   n : Số lượng kênh đầu ra song song (tương ứng với số hàng của ma trận P).
%
% Đầu ra:
%   P : Ma trận kết quả kích thước (n x num_cols). 
%       Mỗi hàng đại diện cho một kênh dữ liệu.

    % 1. Tính toán tổng số cột của ma trận đầu ra
    % Tổng số cột = (Tổng số bit) / (Số kênh n)
    num_cols = length(S) / n;
    
    % 2. Khởi tạo ma trận rỗng để tối ưu bộ nhớ (Pre-allocation)
    P = zeros(n, num_cols);
    
    % 3. Biến đếm vị trí bit hiện tại trong chuỗi đầu vào S
    count = 1;
    
    % 4. Vòng lặp duyệt qua từng cụm cột (mỗi cụm có độ rộng m bit)
    for k = 1:m:num_cols
        
        % 5. Vòng lặp duyệt qua từng kênh (tương ứng từng hàng của ma trận)
        for j = 1:n
            
            % Gán một đoạn m bit từ chuỗi S vào kênh thứ j, tại vị trí cột tương ứng
            % Cú pháp P(hàng, cột_bắt_đầu : cột_kết_thúc)
            P(j, k : k+m-1) = S(count : count+m-1);
            
            % Cập nhật biến đếm để lấy nhóm m bit tiếp theo trong chuỗi S
            count = count + m;
            
        end
    end
end