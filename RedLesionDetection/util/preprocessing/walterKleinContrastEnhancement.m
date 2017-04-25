
function [t_output] = walterKleinContrastEnhancement(I, mask, r, W, u_max, u_min) 

    % If the number of input arguments is less than 3, assign default
    % paramenters
    if (nargin < 3)
        r = 2; 
        W = floor(size(I,2) * 25 / 536);
        u_max = 1;
        u_min = 0;
    end
    mask = mask>0;
    
    % get only the green band of the image
    if size(I,3)>1
        I = (I(:,:,2));
    end
    % fakepad the borders
    w = floor(3*(size(I,2))/30);
    [t, mask_extended] = fakepad(im2double(I), mask, 5, w);
    mask_extended = mask_extended > 0;
    
    % compute the mean value on W x W windows
    mu = roifilt2(fspecial('average',[W W]), t, mask_extended>0);
    % get the minimum intensity value of the image
    t_min = min(t(mask_extended));
    % get the maximum intensity value of the image
    t_max = max(t(mask_extended));
    
    % compute the local enhancement
    rt_low = (1/2 * (u_max - u_min) ./ (mu - t_min).^r) .* (t - t_min).^r + u_min;
    rt_high = (-1/2 * (u_max - u_min) ./ (mu - t_max).^r) .* (t - t_max).^r + u_max;

    % use rt_low or rt_high if the intensity value is lower or higher
    % than the mean value in the WxW neighborhood
    t = (double(t <= mu) .* rt_low + double(t > mu) .* rt_high) .* double(mask_extended);
    
    % remove NaN values generated by t - t_min or t-t_max = 0
    t(isnan(t)) = 0;
    
    % Apply a gaussian filter to remove potential noise
    t = imfilter(t, fspecial('gaussian', 5, 1));

    % rebuild current color band
    t_output = zeros(size(I));
    t_output(mask) = t(mask_extended>0);
    
end





