function out = hann(N)

o   = sin(pi*(0:N-1)/(N-1)).^2;
out = o';

end