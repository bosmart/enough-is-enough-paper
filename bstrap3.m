function [val, ci, sem] = bstrap3(data, n, K, repl)
%BSTRAP Randomly sample from data, with or without replacement.
%
%   Inputs:
%       data    row or column vector of observations
%       n       number of bootstrap samples (default: 100)
%       K       sample size (default: 2:50), can be a range or a scalar
%       repl    sample with replacement (default: true)
%
%   Outputs:
%       val     the value for k=1
%       ci      95% confidence interval
%       sem     standard errors for each bootstrap sample/value of K
%
%   Example:
%       data = csvread('data.csv');
%       [val, ci, sem] = bstrap(data, 50, 5:10, true);
%
%   For Octave users - requires the 'optim' package from Octave-forge.
%       pkg install -forge optim
%       pkg load optim

    if nargin < 2 || isempty(n), n = 100; end
	if nargin < 3 || isempty(K), K = 2:50; end
	if nargin < 4 || isempty(repl), repl = true; end
	
% 	orgK = K;
% 	K = [K max(K)+(1:5)];
	
    A = cell(1,numel(K));
	B = nan(max(K), n*numel(K));
	
	result = zeros(numel(K), n);
	for k = 1:numel(K)
		A{k} = zeros(n, K(k));
		for i = 1:n
            if repl
                ix = randi(length(data), 1, K(k));
            else
                ix = randperm(length(data), K(k));
            end
            s = data(ix);
			A{k}(i, :) = s;
			B(1:K(k), i+(k-1)*n) = s;
			result(k, i) = mean(s);
		end		
	end

	sem = cell2mat(cellfun(@(x) std(x,[],2)/sqrt(size(x,2)), A, 'unif', 0));
	
	% jitter the points for plotting	
	K_jit = bsxfun(@plus, K,  2*(rand(size(sem))-0.5)*0.2);
	plot(K_jit', sem', '.');
	hold on
	
	% get means and stdevs for each value of k
	mu = mean(sem, 1);
	sigma = std(sem, 0, 1);
	
	sem1 = sem;
	sem1(sem <= mu) = nan;
	sigma_plus = sqrt(nansum((sem1-mu).^2,1) ./ (sum(~isnan(sem1),1) - 1));
	
	sem1 = sem;
	sem1(sem >= mu) = nan;
	sigma_minus = sqrt(nansum((sem1-mu).^2,1) ./ (sum(~isnan(sem1),1) - 1));
	
% 	plot(K,mu,'LineWidth',3);
% 	plot(K,mu+1.96*sigma,'LineWidth',2);
% 	plot(K,mu-1.96*sigma,'LineWidth',2);

	% fit the mean and 95% ci curves
	order = 6;
	[p0, S0] = polyfit(K, mu, order);
	[p1, S1] = polyfit(K, mu+1.96*sigma_plus, order);
	[p2, S2] = polyfit(K, max(0,mu-1.96*sigma_minus), order);

	Kp = [0 1 K];
	Y0 = polyconf(p0, Kp, S0);
	Y1 = polyconf(p1, Kp, S1);
	Y2 = polyconf(p2, Kp, S2);	
	
	plot(Kp, Y0, 'b-', 'LineWidth', 3);
 	plot(Kp, [Y1; Y2], 'r--', 'LineWidth', 2);
   
	grid on
	hold off
    
    val = Y0(2);
    ci = [Y1(2), Y2(2)];

end
