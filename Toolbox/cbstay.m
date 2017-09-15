function cb = cbstay(varargin);

ha = gca;
pos = get(ha,'Position');
cb = colorbar(varargin{:});
set(ha,'Position',pos);