function [t, solution]=solve_system(interact, units, timespan)
    
    global n_bodies
    global G
    global Gm
    global interactions
    global sign1
    global units2
    
    load('data.mat', 'x', 'y', 'z', 'ux', 'uy', 'uz');
    
    n_bodies = 9;
    interactions = 1:n_bodies; % this means all bodies interact with each other.
    if (interact == 0)
        interactions = 1;
    end
    if (units == 1)
        %convert to SU to AU
        KM2AU = 1.496e+8; %divide km by this to convert to AU
        KMS2AUD = 0.000577548; %multiply
        x = x*1e-3/KM2AU;
        y = y*1e-3/KM2AU;
        z = z*1e-3/KM2AU;
        ux = KMS2AUD*ux*1e-3;
        uy = KMS2AUD*uy*1e-3;
        uz = KMS2AUD*uz*1e-3;
        
    end
    units2 = units; %used in time function, input shouldn't be made global
    
    % Time to get solution on in years
    tsol=(0:0.01:timespan); %0.01 is the time step in years
    
    G=6.67e-11;
    m=1.989e30; % the mass of the sun
    Gm=[G.*m./1e9 22032.09 324858.63 398600.440 ...
        42828.3 126686511 37931207.8 ...
        5793966 6835107].*1e9;
    
    % Mean distance from the sun
    meandist=[7e8 5.79e10 1.082e11 1.496e11 2.279e11 7.783e11 1.426e12 ...
        2.871e12 4.497e12];

    % set x,y,z,vx,vy,vz for each consecutive planet and the tolerances for the
    % solution
    YINIT= zeros(1, 6*n_bodies);
    AbsTol= zeros(1, 6*n_bodies);
    for i=1:n_bodies
        refIndex = (i-1)*6;
        YINIT(1, (refIndex+1):((refIndex)+6))=[x(i) y(i) z(i) ux(i) uy(i) uz(i)];
        if(i==1)
            AbsTol(1,1:6)=[1./1e3
                    1./1e3
                    1./1e3
                    1./1e6
                    1./1e6
                    1./1e6];
        else
            AbsTol(1, (refIndex+1):(refIndex+6))=[sqrt(x(i).^2+y(i).^2+z(i).^2)./meandist(i)./1e6
                    sqrt(x(i).^2+y(i).^2+z(i).^2)./meandist(i)./1e6
                    sqrt(x(i).^2+y(i).^2+z(i).^2)./meandist(i)./1e6
                    sqrt(ux(i).^2+uy(i).^2+uz(i).^2)./1e7 
                    sqrt(ux(i).^2+uy(i).^2+uz(i).^2)./1e7
                    sqrt(ux(i).^2+uy(i).^2+uz(i).^2)./1e7];
        end
    end
    sign1=sign(tsol(end)-tsol(1));
    options=odeset('RelTol',1e-6,'AbsTol',AbsTol,'OutputFcn',@myplotfun);

    % Solve this problem using ODE113 +++++++++++++++++++++++++++++++++++++++++
    [t,solution] = ode113(@solar01,tsol.*365.25.*24.*3600,YINIT,options);
end
% -------------------------------------------------------------------------


% Function describing the time derivatives to be integrated++++++++++++++++
function derivatives=solar01(~,variable)

    global n_bodies;
    global Gm;
    global interactions;

    derivatives=zeros(6.*(n_bodies),1);
    % x, y, z, vx, vy, vz
    for i=1:n_bodies
        ind=interactions; % bodies we are considering interactions between
        i2=ind==i;  % a body can't interact with itself
        ind(i2)=[];

        % square of distance between this planet and the other objects
        R2=(variable((i-1).*6+1)-variable((ind-1).*6+1)).^2+...
            (variable((i-1).*6+2)-variable((ind-1).*6+2)).^2+...
            (variable((i-1).*6+3)-variable((ind-1).*6+3)).^2;
        % inverse square law between body i and the rest of them
        derivatives((i-1).*6+4)=derivatives((i-1).*6+4) ...
            -sum(Gm(ind)'./R2.*(variable((i-1).*6+1)-variable((ind-1).*6+1))./sqrt(R2));% dvx/dt
        derivatives((i-1).*6+5)=derivatives((i-1).*6+5) ...
            -sum(Gm(ind)'./R2.*(variable((i-1).*6+2)-variable((ind-1).*6+2))./sqrt(R2));% dvy/dt
        derivatives((i-1).*6+6)=derivatives((i-1).*6+6) ...
            -sum(Gm(ind)'./R2.*(variable((i-1).*6+3)-variable((ind-1).*6+3))./sqrt(R2));% dvz/dt

        % rate of change of position, because we are solving a second order ODE
        % - always the same
        derivatives((i-1).*6+1)=variable((i-1).*6+4);
        derivatives((i-1).*6+2)=variable((i-1).*6+5);
        derivatives((i-1).*6+3)=variable((i-1).*6+6);
    end
end% -------------------------------------------------------------------------


% Function to output time++++++++++++++++++++++++++++++++++++++++++++++++++
function status = myplotfun(t, ~, ~)
    global sign1;
    global units2;
    timeUnits = 86400*365.25;
    if (units2)
        timeUnits = timeUnits/86400; %Days, when using AU
    end
    if(sign1==1) % check if the solution is going forward or backward-in-time
        if(t/timeUnits>+1) % if last output was 1 year ago
            disp(['Time: ',num2str(t/timeUnits),' yrs']);
        end
    else
        if(t/timeUnits<-1) % if last output was 1 year in future
            disp(['Time: ',num2str(t/timeUnits),' yrs']);
        end
    end    
    status=0;
end