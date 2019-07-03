function [KD grid_centers] = getKernelDensity(input, bandwidth)

m=min(input)-3*bandwidth;
M=max(input)+3*bandwidth;

N_grid=2^10;

grid_centers=linspace(m,M,N_grid);
spacing=grid_centers(2)-grid_centers(1);

bin_edges=[grid_centers-spacing/2 , grid_centers(end)+spacing/2];

freq=2*pi*N_grid/(M-m)*0.5*linspace(0,1,N_grid/2+1);
filter=exp(-0.5*freq.^2*bandwidth^2);
filter=[filter , fliplr(filter(2:end-1))];

%%


PDF1_hist=1*histc(input,bin_edges)/(spacing*length(input));
PDF1_fft=fft(PDF1_hist(1:end-1));

if size(filter) ~= size(PDF1_fft)
    filter=filter';
end
PDF1_fft_filt=filter.*PDF1_fft;
KD=ifft(PDF1_fft_filt);
    
