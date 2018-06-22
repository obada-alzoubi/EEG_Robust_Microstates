function [imap] = OdspCMap(map,ChanPos,varargin)
% dspCMap - Display topographic scalp maps
% ----------------------------------------
% Copyright 2009-2011 Thomas Koenig
% distributed under the terms of the GNU AFFERO General Public License
%
% Usage: dspCMap(map,ChanPos,CStep)
%
% map is the 1xN voltage map to display, where N is the number of electrode
%
% ChanPos contains the electrode positions, either as Nx3 xyz coordinates,
% or as structure withRadius, Theta and Phi (Brainvision convention)
%
% CStep is the size of a single step in the contourlines, a default is used
% if this is not set
%
% There are a series of options that can be set using parameter/value
% pairs:
%
% 'Colormap':   - 'bw' (Black & White)
%               - 'ww' (White & White; only contourlines)
%               - 'br' (Blue & Red; negative blue, positive red, default
%
% 'Resolution'      controls the resolution of the interpolation
% 'NTri'            also controls resolution
% 'Label'           shows the electrode positions and labels them
% 'Gradient' N      shows vectors with gradients at every N-th grid point
% 'GradientScale'   controls the length of these vectors
% 'NoScale'         whether or not a scale is being shown
% 'LevelList'       sets the levellist
% 'Laplacian'       shows the laplacian instead of the data
% 'Plot'            Plots additional x_points 
% 'Linewidth'       Sets linewidth
% 'NoExtrapolation' Prevents maps to be etrapolated)

if isstruct(ChanPos)
    [x,y,z] = VAsph2cart(ChanPos);
else
    if size(ChanPos,1) == 3
        ChanPos = ChanPos';
    end
    x = -ChanPos(:,2)';
    y =  ChanPos(:,1)';
    z =  ChanPos(:,3)';
end

r = sqrt(x.*x + y.*y + z.*z);

x = x ./ r;
y = y ./ r;
z = z ./ r;

%hold off
%cla



CStep = max(abs(map)) / 4;

ShowScale = 1;


NoseRadius = 0;



NoExPol = 1;




ShowLap = 0;




itype = 'v4';





MapLineWidth = 1;




 cmap = 'br';

res = 4;

%if vararginmatch(varargin,'NTri')
%    Nrecurse = varargin{vararginmatch(varargin,'NTri')+1};
%else
%    Nrecurse = 4;
%end


LabelSize = 8;




ll = [];


Theta = acos(z) / pi * 180;
r = sqrt(x.*x + y.* y);
r(r == 0) = 1;

pxG = x./r.*Theta;
pyG = y./r.*Theta;


% No extrapolation
if NoExPol == 1
    xmx = max(abs(pxG));
    ymx = max(abs(pyG));

else
    dist = sqrt(pxG.*pxG + pyG.*pyG);
    r_max = max(dist);
    xmx = r_max;
    ymx = r_max;
end

xa = -xmx:res:xmx;
ya = -ymx:res:ymx;

[xm,ym] = meshgrid(xa,ya);

if ShowLap == 0
    imap = griddata(pxG,pyG,map,xm,ym,itype);
else
    EiCOS = elec_cosines([x',y',z'],[x',y',z']);
    w = real(acos(EiCOS))/pi *180+eye(numel(x));
    w = w.^LapFact;
 
    w = 1./w - eye(numel(x));
    
    lp = w ./ repmat(sum(w,1),numel(x),1);
    lp = -lp + eye(numel(x)); %This laplacian does not work at all, not sharp enough
    imap = griddata(pxG,pyG,map * lp,xm,ym,itype);
end

if NoExPol == 1
    vmap = griddata(pxG,pyG,map,xm,ym,'linear');
    idx = isnan(vmap);
else
    dist = sqrt(xm.*xm + ym.*ym);
    idx = dist > r_max;
end

imap(idx) = 0;

if false
    Delta = varargin{vararginmatch(varargin,'Gradient')+1};
        
    sx = size(imap,1);
    sy = size(imap,2);
    Grad1 = imap(1:sx-Delta,1:sy-Delta  ) - imap((Delta+1):sx,(Delta+1):sy);
    Grad2 = imap(1:sx-Delta,(Delta+1):sy) - imap((Delta+1):sx,1:sy-Delta  );
    
    if false
        gScale = varargin{vararginmatch(varargin,'GradientScale')+1};
    else
        g = sqrt(Grad1.*Grad1 + Grad2 .* Grad2);
        gScale = 1/max(g(:));
    end
    if (gScale == 0)
        gScale = gScale * Delta * res;
        ypgrad = 0;
        for i = 1:Delta:(sx-Delta)
            ypgrad = ypgrad+1;
            yposgrad(ypgrad) = (ya(i)+Delta/2*res);

            xpgrad = 0;
            for j = 1:Delta:(sy-Delta)
                xpgrad = xpgrad+1;
                xposgrad(xpgrad) = (xa(j)+Delta/2*res);
            
                if ~isnan(Grad1(i,j)) && ~isnan(Grad2(i,j));
                    GradMap(ypgrad,xpgrad) = sqrt((Grad1(i,j)- Grad2(i,j)).^2 + (Grad1(i,j)+Grad2(i,j)).^2);
                else
                    GradMap(ypgrad,xpgrad) = 0;
                end
            end
        end
        imap = griddata(xposgrad,yposgrad,GradMap,xm,ym,'v4');
        imap(idx) = 0;
    end
end
end
