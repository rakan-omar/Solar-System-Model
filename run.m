% Planet with longest orbital period: Neptune with 165 years (pluto, 248)

interact = 1; %With this, all planets interact with all planets
%change it to 0 to have the planets interact only with the sun
%Obviously, run time is far longer when all bodies interact with all bodies
%about 8 times slower (since there are 8 times as many calculations

%NOTE: using au is still unsupported, need to adjust tolerances
au = 0; %set to 1 to use AU units, the default is SI Units


% input arguments: interact, au, timespan 
[t, solution] = solve_system(interact, au, 169);

plot_stride=5;
plot_planets = 8;