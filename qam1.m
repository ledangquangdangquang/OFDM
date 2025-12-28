function QAM = qam1(st, M)
% input: vector bit 0 1
% output: vector complex after qammod
    st_reshape = reshape(st.', log2(M), []).';
    st_dec = bi2de(st_reshape, 'left-msb');
    if(M == 2)
    QAM = qammod(st_dec, M).';
    else
    QAM = qammod(st_dec, M) .* exp(-1j*pi/log2(M)).';
    end
end