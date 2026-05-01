function [alpha_hat, beta_hat] = p24(x, y)
    x = x(:);
    y = y(:);
    M = [x, ones(size(x))];
    params = M \ y;
    alpha_hat = params(1);
    beta_hat = params(2);
end