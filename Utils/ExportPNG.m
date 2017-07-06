function [  ] = ExportPNG( filename )
% ExportPNG: Exports a figure to a high resolution .png file.

    set(gcf, 'PaperPositionMode', 'auto');
    print('-painters', '-dpng', filename, '-r300');

end  % ExportPNG
