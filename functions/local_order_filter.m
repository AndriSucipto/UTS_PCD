function out = local_order_filter(I, w, type)
if ndims(I)==3
    out = zeros(size(I),'like',I);
    for c=1:3
        out(:,:,c) = local_order_filter(I(:,:,c), w, type);
    end
    return;
end
pad = floor(w/2);
Ipad = padarray(double(I),[pad pad],'replicate');
[M,N] = size(I);
out = zeros(M,N);
for i=1:M
    for j=1:N
        block = Ipad(i:i+w-1, j:j+w-1);
        v = sort(block(:));
        switch type
            case 'min', out(i,j)=v(1);
            case 'max', out(i,j)=v(end);
            case 'median', out(i,j)=v(ceil(end/2));
            otherwise, out(i,j)=v(ceil(end/2));
        end
    end
end
out = cast(out, class(I));
end
