clear;
%% 1. ĐỌC FILE VÀ THIẾT LẬP THAM SỐ
[yr, fs] = audioread('ofdm_signal.wav'); % Đọc tín hiệu âm thanh thu được
fc = 2400;         % Tần số sóng mang (Hz)
M = 4;             % Mức điều chế (4-QAM)
N = 8;             % Tổng số subcarriers (kích thước FFT)
K = 4;             % Số lượng subcarriers mang dữ liệu thực tế
Z = N - K;         % Số lượng subcarriers bảo vệ (Guard carriers)
G = 4;             % Độ dài Cyclic Prefix (CP)
Df = 2;            % Khoảng cách Pilot theo tần số (không gian subcarrier)
Dt = 2;            % Khoảng cách Pilot theo thời gian (không gian symbol)

% Ma trận mẫu Pilot (dùng để ước lượng kênh truyền)
pilot_matrix = [1 0 1; 0 0 0; 1 0 1; 0 0 0]; 

%% 2. GIẢI ĐIỀU CHẾ SÓNG MANG (DOWN-CONVERSION)
n = 0:length(yr)-1;
t = n/fs;
xs = sin(2*pi*fc*t); % Thành phần Quadrature (Sin)
xc = cos(2*pi*fc*t); % Thành phần In-phase (Cos)

% Nhân tín hiệu thu với sóng mang nội để đưa về băng tần cơ sở
Hr1 = xs .* yr';
Hr2 = xc .* yr';

% Thiết kế bộ lọc thông thấp (Butterworth bậc 5) để loại bỏ thành phần tần số cao
[b, a] = butter(5, 1/10);
Gr1 = filter(b, a, Hr1);
Gr2 = filter(b, a, Hr2);
Gr = Gr1 + 1j*Gr2; % Tín hiệu phức sau khi lọc

%% 3. XỬ LÝ KHUNG OFDM (FRAME RECOVERY)
% Lấy mẫu lại (Downsampling) với chu kỳ 20 để khôi phục tốc độ baud
Er = Gr(20:20:end); 

% Tách tín hiệu thành từng Symbol (mỗi symbol gồm FFT + CP)
Er = reshape(Er, N+G, []);

% Loại bỏ Cyclic Prefix (CP) để lấy phần dữ liệu chính
Dr = Er(G+1: end,:);

% Chuyển đổi từ miền thời gian sang miền tần số bằng FFT
Cr = fft(Dr);
Br = Cr;

%% 4. LOẠI BỎ CÁC SUB-CARRIERS KHÔNG CẦN THIẾT
mid = N/2;                       % Vị trí DC
Br(mid:mid+Z-2, :) = [];          % Loại bỏ các dải bảo vệ (Guard bands) ở giữa phổ
Br(1,:) = [];                     % Loại bỏ thành phần DC (tần số 0)

%% 5. ƯỚC LƯỢNG KÊNH VÀ GIẢI ĐIỀU CHẾ DỮ LIỆU
% Hàm auto_depilot (tự viết): Dùng pilot_matrix để nội suy đáp ứng kênh 
% và san bằng nhiễu (Equalization) cho ma trận Br
X = auto_depilot(Br, pilot_matrix);

% Tìm các vị trí Pilot để loại bỏ chúng, chỉ giữ lại Symbol dữ liệu
pilot_index = find(pilot_matrix == 1);
X(pilot_index) = [];

% Giải điều chế QAM (từ symbol phức sang các bit nhị phân)
A = qamde1(X, M);

%% 6. TÁI CẤU TRÚC DỮ LIỆU BIT (BIT RECONSTRUCTION)
% Hàm reshapebit (tự viết): Sắp xếp lại các bit từ chuỗi symbol
% thành ma trận có K hàng theo cấu trúc OFDM ban đầu
st_matrix = reshapebit(A, K);

% Trải phẳng ma trận bit thành chuỗi bit hàng ngang duy nhất
st_rx = st_matrix(:).';

% Hiển thị chuỗi bit kết quả cuối cùng thu được
disp(st_rx);