function st_rx = qamde1(QAM, M)
% input: vector complex after qammod
% output: vector bit 0 1
     if M == 2
             DEMOD = qamdemod(QAM, M);
     else
             DEMOD = qamdemod(QAM  .* exp(1j*pi/log2(M)), M);
     end
    st_bin = de2bi(DEMOD, 'left-msb');
    % st_rx = reshape(st_bin.', [], 1).';
    st_rx = st_bin;
end