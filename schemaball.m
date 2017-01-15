function h = schemaball(r, lbls, ccolor, ncolor)

% SCHEMABALL Plots correlation matrix as a schemaball
%
%   SCHEMABALL(R) R is a square numeric matrix with values in [-1,1].
%
%                 NOTE: only the off-diagonal lower triangular section of R is
%                       considered, i.e. tril(r,-1).
%
%   SCHEMABALL(..., LBLS, CCOLOR, NCOLOR) Plot schemaball with optional
%                                         arguments (accepts empty args).
%
%       - LBLS      Plot a schemaball with custom labels at each node.
%                   LBLS is either a cellstring of length M, where
%                   M = size(r,1), or a M by N char array, where each
%                   row is a label.
%
%       - CCOLOR    Supply an RGB triplet that specifies the color of
%                   the curves. CURVECOLOR can also be a 2 by 3 matrix
%                   with the color in the first row for negative
%                   correlations and the color in the second row for
%                   positive correlations.
%
%       - NCOLOR    Change color of the nodes with an RGB triplet.
%
%
%   H = SCHEMABALL(...) Returns a structure with handles to the graphic objects
%
%       h.l     handles to the curves (line objects), one per color shade.
%               If no curves fall into a color shade that handle will be NaN.
%       h.s     handle  to the nodes (scattergroup object)
%       h.t     handles to the node text labels (text objects)
%
%
% Examples
%
%   % Base demo
%   schemaball
%
%   % Supply your own correlation matrix (only lower off-diagonal triangular part is considered)
%   x = rand(10).^3;
%   x(:,3) = 1.3*mean(x,2);
%   schemaball(x)
%
%   % Supply custom labels as ['aa'; 'bb'; 'cc'; ...] or {'Hi','how','are',...}
%   schemaball(x, repmat(('a':'j')',1,2))
%   schemaball(x, {'Hi','how','is','your','day?', 'Do','you','like','schemaballs?','NO!!'})
%
%   % Customize curve colors
%   schemaball([],[],[1,0,1;1 1 0])
%
%   % Customize node color
%   schemaball([],[],[],[0,1,0])
%
%   % Customize manually other aspects
%   h   = schemaball;
%   set(h.l(~isnan(h.l)), 'LineWidth',1.2)
%   set(h.s, 'MarkerEdgeColor','red','LineWidth',2,'SizeData',100)
%
%
% Additional features:
% - <a href="matlab: web('http://www.mathworks.com/matlabcentral/fileexchange/42279-schemaball','-browser')">FEX schemaball page</a>
% - <a href="matlab: web('http://www.stackoverflow.com/questions/17038377/how-to-visualize-correlation-matrix-as-a-schemaball-in-matlab/17111675','-browser')">Origin: question on Stackoverflow.com</a>
% - <a href="matlab: web('https://github.com/GuntherStruyf/matlab-tools/blob/master/schemaball.m','-browser')">Schemaball by Gunther Struyf</a>
%
% See also: CORR, CORRPLOT

% Author: Oleg Komarov (oleg.komarov@hotmail.it)
% Tested on R2013a Win7 64 and Vista 32
% 15 jun 2013 - Created

% TODO
% - Add backward compatibility until R14SP3 (7.1)
% - Allow custom colormaps

%% Parameters
% Tweak these only

% Number of color shades/buckets (large N simply creates many perceptually indifferent color shades)
N      = 20;
% Points in [0, 1] for bezier curves: leave space at the extremes to detach a bit the nodes.
% Smaller step will use more points to plot the curves.
t      = (0.025: 0.05 :1)';
% Nodes edge color
ecolor = [.25 .103922 .012745];
% Text color
tcolor = [.7 .7 .7];

%% Checks

% Ninput
narginchk(0,4)

% Some defaults
if nargin < 1 || isempty(r);        r      = (rand(50)*2-1).^29;                                  end
sz = size(r);
if nargin < 2 || isempty(lbls);     lbls   = cellstr(reshape(sprintf('%-4d',1:sz(1)),4,sz(1))');  end
if nargin < 4 || isempty(ncolor);   ncolor = [0 0 1];                                             end

% R
if ~isnumeric(r) || any(abs(r(:)) > 1) || sz(1) ~= sz(2) || numel(sz) > 2 || sz(1) < 3
    error('schemaball:validR','R should be a square numeric matrix with values in [-1, 1].')
end

% Lbls
if (~ischar(lbls) || size(lbls,1) ~= sz(1)) && (~iscellstr(lbls) || ~isvector(lbls) || length(lbls) ~= sz(1))
    error('schemaball:validLbls','LBLS should either be an M by N char array or a cellstring of length M, where M is size(R,1).')
end
if ischar(lbls)
    lbls = cellstr(lbls);
end

% Ccolor
if nargin < 3 || isempty(ccolor);
    ccolor = hsv2rgb([[linspace(.8333, .95, N); ones(1, N); linspace(1,0,N)],...
                      [linspace(.03, .1666, N); ones(1, N); linspace(0,1,N)]]');
else
    szC = size(ccolor);
    if ~isnumeric(ccolor) || szC(2) ~= 3  || szC(1) > 2
        error('schemaball:validCcolor','CCOLOR should be a 1 by 3 or 2 by 3 numeric matrix with RGB colors.')
    elseif szC(1) == 1
        ccolor = [ccolor; ccolor];
    end
    ccolor = rgb2hsv(ccolor);
    ccolor = hsv2rgb([repmat(ccolor(1,1:2),N,1), linspace(ccolor(1,end),0,N)';
                      repmat(ccolor(2,1:2),N,1), linspace(0,ccolor(2,end),N)']);
end

% Ncolor
szN = size(ncolor);
if ~isnumeric(ncolor) || szN(2) ~= 3  || szN(1) > 1
    error('schemaball:validNcolor','NCOLOR should be a single RGB color, i.e. a numeric row triplet.')
end
ncolor = rgb2hsv(ncolor);
%% Engine

% Create figure
figure('renderer','zbuffer','visible','off')
axes('NextPlot','add')

% Index only low triangular matrix without main diag
tf = tril(true(sz),-1);

% Index correlations into bucketed colormap to determine plotting order (darkest to brightest)
N2        = 2*N;
[n, isrt] = histc(r(tf), linspace(-1,1 + eps(100),N2 + 1));
plotorder = reshape([N:-1:1; N+1:N2],N2,1);

% Retrieve pairings of nodes
[row,col] = find(tf);

% Use tau http://tauday.com/tau-manifesto
tau   = 2*pi;
% Positions of nodes on the circle starting from (0,-1), useful later for label orientation
step  = tau/sz(1);
theta = -.25*tau : step : .75*tau - step;
% Get cartesian x-y coordinates of the nodes
x     = cos(theta);
y     = sin(theta);

% PLOT BEZIER CURVES
% Calculate Bx and By positions of quadratic Bezier curves with P1 at (0,0)
% B(t) = (1-t)^2*P0 + t^2*P2 where t is a vector of points in [0, 1] and determines, i.e.
% how many points are used for each curve, and P0-P2 is the node pair with (x,y) coordinates.
t2  = [1-t, t].^2;
s.l = NaN(N2,1);
% LOOP per color bucket
for c = 1:N2
    pos = plotorder(c);
    idx = isrt == pos;
    if nnz(idx)
        Bx     = [t2*[x(col(idx)); x(row(idx))]; NaN(1,n(pos))];
        By     = [t2*[y(col(idx)); y(row(idx))]; NaN(1,n(pos))];
        s.l(c) = plot(Bx(:),By(:),'Color',ccolor(pos,:),'LineWidth',1);
    end
end

% PLOT NODES
% Do not rely that r is symmetric and base the mean on lower triangular part only
[row,col]  = find(tf(end:-1:1,end:-1:1) | tf);
subs       = col;
iswap      = row < col;
tmp        = row(iswap);
row(iswap) = col(iswap);
col(iswap) = tmp;
% Plot in brighter color those nodes which on average are more absolutely correlated
[Z,isrt]   = sort(accumarray(subs,abs(r( row + (col-1)*sz(1) )),[],@mean));
Z          = (Z-min(Z)+0.01)/(max(Z)-min(Z)+0.01);
ncolor     = hsv2rgb([repmat(ncolor(1:2), sz(1),1) Z*ncolor(3)]);
s.s        = scatter(x(isrt),y(isrt),[], ncolor,'fill','MarkerEdgeColor',ecolor,'LineWidth',1);

% PLACE TEXT LABELS such that you always read 'left to right'
ipos       = x > 0;
s.t        = zeros(sz(1),1);
s.t( ipos) = text(x( ipos)*1.1, y( ipos)*1.1, lbls( ipos),'Color',tcolor);
set(s.t( ipos),{'Rotation'}, num2cell(theta(ipos)'/tau*360))
s.t(~ipos) = text(x(~ipos)*1.1, y(~ipos)*1.1, lbls(~ipos),'Color',tcolor);
set(s.t(~ipos),{'Rotation'}, num2cell(theta(~ipos)'/tau*360 - 180),'Horiz','right')

% ADJUST FIGURE height width to fit text labels
xtn        = cell2mat(get(s.t,'extent'));
post       = cell2mat(get(s.t,'pos'));
sg         = sign(post(:,2));
posfa      = cell2mat(get([gcf gca],'pos'));
% Calculate xlim and ylim in data units as x (y) position + extension along x (y)
ylims      = post(:,2) + xtn(:,4).*sg;
ylims      = [min(ylims), max(ylims)];
xlims      = post(:,1) + xtn(:,3).*sg;
xlims      = [min(xlims), max(xlims)];
% Stretch figure
posfa(1,3) = (( diff(xlims)/2 - 1)*posfa(2,3) + 1) * posfa(1,3);
posfa(1,4) = (( diff(ylims)/2 - 1)*posfa(2,4) + 1) * posfa(1,4);
% Position it a bit lower (movegui slow)
posfa(1,2) = 100;

% Axis settings
set(gca, 'Xlim',xlims,'Ylim',ylims, 'color', 'k','XColor','none','YColor','none',...
         'clim',[-1,1])
set(gcf, 'pos' ,posfa(1,:),'Visible','on')
axis equal

% Set colormap
colormap(gca,ccolor);

if nargout == 1
    h = s;
end
end