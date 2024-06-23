% Definição dos parâmetros
latitude = -26.899251; % Latitude do local (Indaial, SC)
tilt_angle = 25; % Ângulo de inclinação do coletor
albedo = 0.2; % Albedo (refletividade) do solo
day_of_year = 172; % Dia do ano (172 corresponde ao solstício de inverno no hemisfério sul)

% Definição dos ângulos horários e horas do dia
hour_angles = 75:-15:-75;
hours = 7:17;

% Cálculo das constantes
A_const = 1160 + 75 * sind((360/365) * (day_of_year - 275));
k_const = 0.174 + 0.035 * sind((360/365) * (day_of_year - 100));
solar_declination = -23.45 * sind((360/365) * (day_of_year - 81));
C_const = 0.095 + 0.04 * sind((360/365) * (day_of_year - 100));

% Cálculo do ângulo de altitude solar
solar_altitude_angle = asind(cosd(-latitude) * cosd(solar_declination) * cosd(hour_angles) + sind(-latitude) * sind(solar_declination));

% Cálculo da razão da massa de ar
air_mass_ratio = 1 ./ sind(solar_altitude_angle);

% Cálculo da radiação direta
direct_radiation = A_const .* exp(-k_const .* air_mass_ratio);
direct_radiation(solar_altitude_angle < 0) = 0; % Radiação direta é zero quando o sol está abaixo do horizonte

% Cálculo da radiação difusa horizontal
diffuse_radiation_horizontal = C_const .* direct_radiation;

% Cálculo do ângulo azimutal solar
solar_azimuth_angle_solar = asind(cosd(solar_declination) * sind(hour_angles) ./ cosd(solar_altitude_angle));
solar_azimuth_angle_correction = 0; % Correção do ângulo azimutal solar
solar_azimuth_angle = solar_azimuth_angle_solar - solar_azimuth_angle_correction;

% Cálculo do ângulo de incidência
incident_angle = acosd(cosd(solar_altitude_angle) .* cosd(solar_azimuth_angle) .* sind(tilt_angle) + sind(solar_altitude_angle) .* cosd(tilt_angle));

% Cálculo da radiação total para um coletor fixo
direct_radiation_fixed = direct_radiation .* cosd(incident_angle);
diffuse_radiation_fixed = diffuse_radiation_horizontal .* ((1 + cosd(tilt_angle)) / 2);
reflected_radiation_fixed = albedo .* direct_radiation .* (sind(solar_altitude_angle) + C_const) .* ((1 - cosd(tilt_angle)) / 2);
total_radiation_fixed = direct_radiation_fixed + diffuse_radiation_fixed + reflected_radiation_fixed;

% Cálculo da radiação total para um coletor com rastreamento de 1 eixo
direct_radiation_tracker1 = direct_radiation .* cosd(latitude);
diffuse_radiation_tracker1 = C_const .* direct_radiation .* ((1 + cosd(90 - solar_altitude_angle + solar_declination)) / 2);
reflected_radiation_tracker1 = albedo .* direct_radiation .* (sind(solar_altitude_angle) + C_const) .* ((1 - cosd(90 - solar_altitude_angle + solar_declination)) / 2);
total_radiation_tracker1 = direct_radiation_tracker1 + diffuse_radiation_tracker1 + reflected_radiation_tracker1;

% Cálculo da radiação total para um com coletor de 2 eixos
direct_radiation_tracker2 = direct_radiation;
diffuse_radiation_tracker2 = C_const .* direct_radiation .* ((1 + cosd(90 - solar_altitude_angle)) / 2);
reflected_radiation_tracker2 = albedo .* direct_radiation .* (sind(solar_altitude_angle) + C_const) .* ((1 - cosd(90 - solar_altitude_angle)) / 2);
total_radiation_tracker2 = direct_radiation_tracker2 + diffuse_radiation_tracker2 + reflected_radiation_tracker2;

% Plotagem dos resultados
plot(hours, total_radiation_fixed, 'r');
hold on;
plot(hours, total_radiation_tracker1, 'g');
plot(hours, total_radiation_tracker2, 'b');
title('Geração Fotovoltaica Inverno Indaial');
xlabel('Hora do Dia');
ylabel('Geração (W/m²)');
legend('Coletor Fixo', 'Coletor com 1 Eixo', 'Coletor com 2 Eixos');
hold off;

% Impressão dos resultados no console
fprintf('Hora ; Coletor Fixo ; Coletor 1 Eixo; Coletor 2 Eixos\n');
for i = 1:length(hours)
    fprintf('%6.2f; %6.2f ; %6.2f ; %6.2f\n', hours(i), total_radiation_fixed(i), total_radiation_tracker1(i), total_radiation_tracker2(i));
end
fprintf('\n');
