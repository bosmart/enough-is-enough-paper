% n - number of samples (default: 100)
% K - sample size (default: 2:50), can be a range or a single number
% repl - with replacement (default: true)

function [out1, out2, out3, out4, out5, sem] = bootstrap3(data, n, K, repl)

	if nargin < 2 || isempty(n), n = 100; end
	if nargin < 3 || isempty(K), K = 2:50; end
	if nargin < 4 || isempty(repl), repl = true; end
	
	out4 = cell(1,numel(K));
	out5 = nan(max(K), n*numel(K));
	
	result = zeros(numel(K), n);
	for k = 1:numel(K)
		out4{k} = zeros(n, K(k));
		for i = 1:n
			s = datasample(data, K(k), 'Replace', repl);
 			out4{k}(i, :) = s;
 			out5(1:K(k), i+(k-1)*n) = s;
			result(k, i) = mean(s);
		end		
	end

	out1 = mean(result, 2);
	out2 = std(result, [], 2);
	out3 = result;
	
	sem = cell2mat(cellfun(@(x) std(x,[],2)/sqrt(size(x,2)), out4, 'unif', 0));
	
% 	[xData, yData] = prepareCurveData([], sem);
% 
% 	% Set up fittype and options.
% 	ft = fittype( 'poly3' );
% 
% 	% Fit model to data.
% 	[fitresult, gof] = fit( xData, yData, ft );
% 
% 	% Plot fit with data.
% 	figure( 'Name', 'untitled fit 2' );
% 	h = plot( fitresult, xData, yData, 'predobs' );
% 	legend( h, 'sem', 'untitled fit 2', 'Lower bounds (untitled fit 2)', 'Upper bounds (untitled fit 2)', 'Location', 'NorthEast' );
% 	% Label axes
% 	ylabel sem
% 	grid on
% 
% 	return
	
	
% 	K_jit = K + 2*(rand(size(sem))-0.5)*0.2;
	K_jit = bsxfun(@plus, K,  2*(rand(size(sem))-0.5)*0.2);
	plot(K_jit', sem', '.');
	hold on
	fopts = fitoptions;
	fopts.Normalize = 'off';
	
	fitobject = fit(reshape(repmat(K,size(sem,1),1),[],1), reshape(sem,[],1), 'poly3', fopts);
	plot(fitobject, 'predobs');
	[ypred,yfit] = predint(fitobject,K,0.95,'observation');
	disp(fitobject(1));
	disp(ypred(1,:));
	
% 	ci = confint(fitobject);
% 	fitobject.p1 = fitobject.p1 + ci(1,1);
% 	fitobject.p2 = fitobject.p2 + ci(1,2);
% 	fitobject.p3 = fitobject.p3 + c1(1,3);
% 	fitobject.p4 = fitobject.p4 + ci(1,4);
% 	fitobject.p5 = fitobject.p5 + ci(1,5);
% 	plot(fitobject);
	grid on
	hold off
end


% the one with the for loop on Slack