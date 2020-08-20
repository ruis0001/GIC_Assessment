% =============================================
% =       GIC Non-uniform Condcutivity        =
% =   Rui Sun, Dominion Technical Solutions   =
% =============================================

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 4
% =============================================

function Weight = st04_GIC_GeoMagCoordinateCov(Line_Lat1,Line_Lon1)  % Based on 2014 Geomagnetic Coordinate System

Weight = zeros(1,length(Line_Lat1));

Dlon = -72.54;	% Earth's magnetic south pole (which is near the geographic north pole!) (2014)
Dlat = 80.316;  % latitude (in degrees) of same (2014)
R = 1;  % distance from planet center (value unimportant -- just need a length for conversion to rectangular coordinates)

Dlon=Dlon*pi/180;    % convert first to radians
Dlat=Dlat*pi/180;

glat = Line_Lat1.*pi/180.0;
glon = Line_Lon1.*pi/180.0;
galt = glat.*0.+R;
coord = [glat; glon; galt];

% convert to rectangular coordinates
for i = 1:length(coord(1,:))
    x(i) = coord(3,i)*cos(coord(1,i))*cos(coord(2,i));
    y(i) = coord(3,i)*cos(coord(1,i))*sin(coord(2,i));
    z(i) = coord(3,i)*sin(coord(1,i));
end

% computer 1st rotation matrix:
geo2maglon = zeros(3,3);
geo2maglon(1,1) = cos(Dlon);
geo2maglon(1,2) = sin(Dlon);
geo2maglon(2,1) = -sin(Dlon);
geo2maglon(2,2) = cos(Dlon);
geo2maglon(3,3) = 1;
out = geo2maglon*[x; y; z];

% Second rotation : in the plane of the current meridian from geographic pole to magnetic dipole pole.
tomaglat = zeros(3,3);
tomaglat(1,1) = cos(.5*pi-Dlat);
tomaglat(1,3) = -sin(.5*pi-Dlat);
tomaglat(3,1) = sin(.5*pi-Dlat);
tomaglat(3,3) = cos(.5*pi-Dlat);
tomaglat(2,2) = 1;
out = tomaglat*out;

% convert back to latitude, longitude and altitude
for i = 1:length(coord(1,:))
    mlat(i) = atan2(out(3,i),sqrt(out(1,i)^2+out(2,i)^2));
    mlat(i) = mlat(i)*180/pi;
    mlon(i) = atan2(out(2,i), out(1,i));
    mlon(i) = mlon(i)*180/pi;      
    Weight(1,i) = 0.001*exp(0.115*mlat(i));    % Use non-uniform Geomagnetic Latitude scaling
end  
    
%Weight = Weight.*switch1;
end