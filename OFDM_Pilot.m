clc; clear; close all;

%% ===== 1. THIẾT LẬP THAM SỐ OFDM =====
M = 4;              % Mức điều chế (4-QAM = 2 bit/symbol)
N = 8;              % Kích thước FFT (Tổng số subcarriers)
K = 4;              % Số subcarriers thực tế dùng để truyền dữ liệu
Z = N - K;          % Số subcarriers bảo vệ (Guard carriers) để tránh nhiễu
G = 4;              % Độ dài Cyclic Prefix (CP)
Df = 2;             % Khoảng cách Pilot theo tần số
Dt = 2;             % Khoảng cách Pilot theo thời gian
st = [1 0 1 1 0 0 1 0 1 1 0 0 0 1 0 1]; % Chuỗi bit dữ liệu đầu vào
%% ===== 2. ĐIỀU CHẾ VÀ CHÈN PILOT =====
% Tách chuỗi bit thành ma trận K hàng (mỗi hàng tương ứng 1 kênh dữ liệu)
A = S2P(st, 1, K); 

% Giải điều chế từng hàng bit sang ký hiệu QAM phức (Hàm qam1 tự định nghĩa)
B = zeros(K, size(A, 2)/log2(M)); 
for i = 1:K
    B(i, :) = qam1(A(i, :), M);
end

% Chèn tín hiệu Pilot vào ma trận dữ liệu (Dùng để bên thu ước lượng kênh)
B = pilot(B, K, Df, Dt);
%% NOTE: 
% đang thử test dữ liệu st dài hơn (thêm 1 sysmbol)
% mới sửa lại cái pilot để thích ứng với nhiều Df Dt K hơn 
% có vẻ code chạy được nhưng chưa biết làm sao chắc đúng 
% thì thêm nhiều bit nên pilot đang lỗi
%% ===== 3. ÁNH XẠ SUB-CARRIERS (RESOURCES MAPPING) =====
% Tạo cấu trúc khung OFDM trong miền tần số
zero = zeros(1, size(B,2));
C = [
    zero                 % Hàng 1: DC subcarrier (thường để trống để tránh nhiễu DC)
    B(1:K/2, :)          % Nửa đầu dữ liệu
    repmat(zero, Z-1, 1) % Chèn các Guard bands ở giữa phổ
    B(K/2+1:end, :)      % Nửa sau dữ liệu
];

% Biến đổi IFFT: Chuyển tín hiệu từ miền tần số sang miền thời gian
D = ifft(C);

%% ===== 4. THÊM CYCLIC PREFIX (CP) =====
% Lấy một phần đuôi của symbol đưa lên đầu để chống nhiễu liên ký hiệu (ISI)
E = [D(end-G+1:end, :); D];

% Trải phẳng ma trận thành chuỗi tín hiệu thời gian liên tục
F = reshape(E, 1, []);
G1 = real(F); % Thành phần thực (In-phase)
G2 = imag(F); % Thành phần ảo (Quadrature)

%% ===== 5. NÂNG MẪU (UPSAMPLING) =====
L = 20; % Hệ số nâng mẫu (mỗi mẫu được lặp lại 20 lần)
H1 = kron(G1, ones(1,L));
H2 = kron(G2, ones(1,L));

%% ===== 6. ĐƯA LÊN SÓNG MANG ÂM TẦN (I/Q MODULATION) =====
fs = 48000;        % Tần số lấy mẫu âm thanh (Standard Audio FS)
fc = 2400;         % Tần số sóng mang âm thanh (2.4 kHz)

% Trả lời câu hỏi: fs / fc = L (48000/2400 = 20)
% Việc chọn L = fs/fc giúp đảm bảo rằng mỗi chu kỳ của sóng mang có đúng L mẫu.
% Điều này giúp việc giải điều chế ở bên thu (tách sóng) trở nên đồng bộ và chính xác hơn.

n = 0:length(H1)-1;
t = n/fs;
xs = sin(2*pi*fc*t); % Sóng mang nhánh Sin
xc = cos(2*pi*fc*t); % Sóng mang nhánh Cos

%% ===== 7. TRỘN TÍN HIỆU VÀ XUẤT FILE =====
I = H1 .* xs;       % Điều chế nhánh I
Q = H2 .* xc;       % Điều chế nhánh Q
ofdm = I + Q;       % Tín hiệu OFDM cuối cùng (tín hiệu thực)

% Phát âm thanh tín hiệu OFDM (nghe như tiếng rít/nhiễu)
sound(ofdm, fs);    
audiowrite('ofdm_signal.wav', ofdm, fs); % Lưu thành file wav để truyền đi

%% ===== 8. HIỂN THỊ ĐỒ THỊ =====
% Vẽ các bước trung gian để quan sát quá trình điều chế
figure
subplot(7,1,1); plot(H1); title('I baseband (Sau nâng mẫu)')
subplot(7,1,2); plot(H2); title('Q baseband (Sau nâng mẫu)')
subplot(7,1,3); plot(xs); title('Sóng mang Sin')
subplot(7,1,4); plot(xc); title('Sóng mang Cos')
subplot(7,1,5); plot(I); title('Nhánh I sau điều chế')
subplot(7,1,6); plot(Q); title('Nhánh Q sau điều chế')
subplot(7,1,7); plot(ofdm); title('Tín hiệu OFDM tổng hợp')