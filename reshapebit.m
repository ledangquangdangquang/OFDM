function st_matrix = reshapebit(A, K)
% Chuyển các symbol thành cấu trúc ma trận K hàng
% A: Ma trận bit đầu vào (mỗi hàng là bit của 1 symbol)
% K: Số lượng subcarriers dữ liệu (số hàng mong muốn)

% 1. Tự động lấy số lượng bit của mỗi symbol (số cột của A)
[num_symbols, num_bits_per_symbol] = size(A);

% 2. Kiểm tra điều kiện đầu vào để tránh lỗi chia dư
if mod(num_symbols, K) ~= 0
    warning('Tổng số symbol không chia hết cho K. Một số dữ liệu có thể bị bỏ qua.');
    num_symbols = floor(num_symbols / K) * K;
    A = A(1:num_symbols, :);
end

num_ofdm_cols = num_symbols / K; % Số lượng cột OFDM (khung thời gian)
% Cấp phát bộ nhớ: K hàng x (Số cột OFDM * Số bit mỗi symbol)
st_matrix = zeros(K, num_ofdm_cols * num_bits_per_symbol);

% 3. Vòng lặp quét qua từng cột OFDM
for col = 1:num_ofdm_cols
    % Xác định dải chỉ số của các symbol thuộc cột OFDM hiện tại
    idx_start = (col-1)*K + 1;
    idx_end   = col*K;
    
    % Lấy khối K symbols (tương ứng 1 cột trong lưới OFDM)
    current_block = A(idx_start:idx_end, :); 
    
    % 4. Vòng lặp lồng để xử lý từng "lớp" bit của symbol
    for b = 1:num_bits_per_symbol
        % Tính toán vị trí cột chính xác trong st_matrix
        target_col = (col-1)*num_bits_per_symbol + b;
        
        % Đổ toàn bộ K hàng cho cột bit thứ b
        st_matrix(:, target_col) = current_block(:, b);
    end
end
end