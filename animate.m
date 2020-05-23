% create animation of solar system
figure('renderer','openGL', 'Color', 'black', 'position', [200 200 1000 1000]);
global h;
% Plot the paths of the planets
for j=1:8
    h(j)=plot3(solution(:,1+j*6)-solution(:,1),solution(:,2+j*6)-solution(:,2),solution(:,3+j*6)-solution(:,3),'linewidth',0.5);hold on;
end
axis equal
xlabel('x');
ylabel('y');
zlabel('z');

set(gca,'Color','k')

col=[235, 183, 183; 220, 220, 220; 97, 176, 154; 227, 125, 41; ...
    237, 174, 64; 255, 201, 74; 117, 211, 224; 62, 169, 184]/255;

radii = [2439.7 6051.8 6371 3389.5 69911 58232 25362 24622];
diameters = radii*2;


%Here we have two issues, with scaling: basically, the stupid solar system
%is too big
%distance between Neptune to sun is about 4000 times larger than the Sun's
%diameter. making it hard to model it so that we can see everything to scale
%on a screen (the 4 inner planets would be so small, they'd be invisible)

%secondly, for our purposes of modelling asteroids, we run into a similar
%scale issue, so, I think when we model asteroids, we can keep the
%calculations to include all planets, but then only plot the inner planets

%alternatively, we could scale nonlinearly (logs, square roots, etc.)

% Scale the sizes of the planets 
sz = diameters*1.5e-3; 
%for now, I found the above to be the best size (venus visible on zooming,
%and Juptier doesn't swallow everything)

k=1;
% Loop over all frames
for i=1:plot_stride:length(t)
    for j=1:8
        h(j)=plot3(solution(i,1+j*6)-solution(i,1),solution(i,2+j*6)-solution(i,2),solution(i,3+j*6)-solution(i,3),...
            '.','color',col(j, :),'markersize',sz(j));hold on;
    end
    pause(0.01);
    k=k+1;
    delete(h); %if you close the window during simulation, this line might
    %give an error. I'll add a conditional, but checking if h exists is
    %actually difficult
end