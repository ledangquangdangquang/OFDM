function X_equalized = auto_depilot(Br, pilot_matrix)
% AUTO_DEPILOT  Channel estimation & equalization using comb pilot
%
% Br            : ma trận sau FFT (K × Ns), đã bỏ DC & guard
% pilot_matrix  : ma trận pilot (K × Ns), pilot = 1, data = 0
% X_equalized   : ma trận sau cân bằng kênh

    [rows, cols] = size(Br);
    H = zeros(rows, cols);

    % --- Tọa độ pilot ---
    [p_row, p_col] = find(pilot_matrix == 1);

    % --- Nội suy theo tần số tại các cột có pilot ---
    for c = unique(p_col).'          % chỉ các OFDM symbol có pilot
        idx = (p_col == c);          % pilot thuộc cột c

        % Giá trị kênh tại pilot (LS vì pilot = 1)
        Hp = Br(sub2ind([rows, cols], p_row(idx), ...
                        c * ones(sum(idx),1)));

        % Nội suy 1D theo tần số
        H(:,c) = interp1( ...
            p_row(idx), Hp, ...
            1:rows, ...
            'nearest', 'extrap');
    end

    % --- Copy kênh sang các cột không có pilot (kênh chậm) ---
    pilot_cols = unique(p_col).';

    for c = 1:cols
        if all(H(:,c) == 0)
            % lấy kênh từ cột pilot gần nhất bên trái
            prev_pilot_col = pilot_cols(find(pilot_cols < c, 1, 'last'));
            if ~isempty(prev_pilot_col)
                H(:,c) = H(:,prev_pilot_col);
            else
                % nếu pilot ở bên phải (trường hợp cột đầu)
                next_pilot_col = pilot_cols(find(pilot_cols > c, 1, 'first'));
                H(:,c) = H(:,next_pilot_col);
            end
        end
    end

    % --- Equalization ---
    X_equalized = Br ./ H;

end
