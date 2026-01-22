%function [reward, rewardVector, action] = legacy_distanceRewarding(this, action)

% persistent previousPosFlex inactiveSteps
% 
% if isempty(previousPosFlex)
%     previousPosFlex = zeros(size(action)); % Inicializa el registro de posición
% end
% if isempty(inactiveSteps)
%     inactiveSteps = 0; % Inicializa el contador de inactividad
% end
% 
% %% Configuración de recompensas
% opts.k = 3; % Penalización suavizada por distancia
% rewards.dirInverse = -5; % Penalización por moverse en dirección incorrecta
% rewards.wrongStop = -15; % Penalización por detenerse incorrectamente
% rewards.goodMove = 15; % Recompensa por moverse en la dirección correcta
% rewards.goodMove2 = 1;
% rewards.inactivityPenalty = -2; % Penalización base por inactividad
% rewards.moveIncentive = 5; % Incentivo por moverse
% rewards.precisionBonus = 10; % Bonificación por precisión
% rewards.smoothnessPenalty = -3; % Penaliza cambios bruscos
% rewards.efficiencyBonus = 3; % Bonificación por movimientos suaves
% 
% rewardVector = zeros(1, 4);
% 
% %% Lectura del estado actual
% if this.c == 1
%     flexConv = this.flexJoined_scaler(reduceFlexDimension(this.flexData));
% else
%     flexConv = this.flexConvertedLog{this.c - 1};
% end
% pos = this.motorData(end, :);
% posFlex = this.flexJoined_scaler(encoder2Flex(pos));
% % disp('posision motor')
% % disp(pos)
% % disp('previousPosFlex')
% % disp(previousPosFlex)
% % disp('posFlex')
% % disp(posFlex)
% % disp('flexConv')
% % disp(flexConv)
% %% Evaluación de recompensa por cada motor
% for i = 1:length(action)
%     if posFlex(i) < flexConv(end, i)
%         correctAction = 1;  % Mover hacia adelante
%     elseif posFlex(i) > flexConv(end, i)
%         correctAction = -1; % Mover hacia atrás
%     else
%         correctAction = 0;  % Mantenerse en su lugar
%     end
% 
%     % Aplicar recompensas y penalizaciones
%     if action(i) == correctAction
%         if action(i) ~= 0
%             rewardVector(i) = rewards.goodMove;
%         else
%             rewardVector(i) = rewards.goodMove2;
%         end
%     elseif action(i) == 0
%         rewardVector(i) = rewards.wrongStop;
%     else
%         rewardVector(i) = rewards.dirInverse;
%     end
% 
%     % Calcular la pendiente del movimiento
%     slope = (posFlex(i) - previousPosFlex(i));
% 
%     % Penalizar cambios bruscos con menor impacto
%     rewardVector(i) = rewardVector(i) + rewards.smoothnessPenalty * sqrt(abs(slope));
% 
%     % Bonificar movimientos eficientes con menor impacto
%     if abs(slope) > 0.01 && abs(slope) < 0.5
%         rewardVector(i) = rewardVector(i) + rewards.efficiencyBonus;
%     end
% end
% 
% % Actualizar el registro de posición
% previousPosFlex = posFlex;
% 
% %% Penalizacion acumulada por inactividad
% if all(action == 0) && correctAction ~= 0  % Si todas las acciones son cero (no movimiento)
%     inactiveSteps = inactiveSteps + 1; % Incrementar el contador de inactividad
%     penalty = rewards.inactivityPenalty * inactiveSteps; % Penalización acumulada
%     rewardVector = rewardVector + penalty; % Aplicar la penalización acumulada
% else
%     inactiveSteps = 0; % Reiniciar el contador de inactividad si se mueve
% end
% 
% % Incentivar movimiento si el agente no se queda inactivo
% if any(action ~= 0)
%     rewardVector = rewardVector + rewards.moveIncentive;
% end
% 
% % Penalización más moderada por distancia usando raíz cuadrada
% distance = abs(posFlex - flexConv(end, :));
% rewardVector = rewardVector - sqrt(distance) .* opts.k;
% 
% % Bonificación suavizada si la distancia es menor a un umbral
% precisionMask = distance < 0.05; % Si la distancia es menor a 5% del rango
% rewardVector(precisionMask) = rewardVector(precisionMask) + rewards.precisionBonus / 2;
% 
% % Calcular la recompensa total con menor varianza
% reward = mean(rewardVector);
% 
% end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% persistent previousPosFlex inactiveSteps previousPhi
% 
% if isempty(previousPosFlex), previousPosFlex = zeros(size(action)); end
% if isempty(inactiveSteps), inactiveSteps = 0; end
% if isempty(previousPhi), previousPhi = 0; end
% 
% opts.k = 3;
% rewards.dirInverse = -5;
% rewards.wrongStop = -15;
% rewards.goodMove = 15;
% rewards.goodMove2 = 1;
% rewards.inactivityPenalty = -2;
% rewards.moveIncentive = 5;
% rewards.precisionBonus = 10;
% rewards.smoothnessPenalty = -3;
% rewards.efficiencyBonus = 3;
% baseShapingGain = 6;
% gamma = 0.99;
% 
% rewardVector = zeros(1, 4);
% 
% % Estado actual
% if this.c == 1
%     flexConv = this.flexJoined_scaler(reduceFlexDimension(this.flexData));
% else
%     flexConv = this.flexConvertedLog{this.c - 1};
% end
% pos = this.motorData(end, :);
% posFlex = this.flexJoined_scaler(encoder2Flex(pos));
% 
% % Recompensas motor por motor
% for i = 1:length(action)
%     if posFlex(i) < flexConv(end, i)
%         correctAction = 1;
%     elseif posFlex(i) > flexConv(end, i)
%         correctAction = -1;
%     else
%         correctAction = 0;
%     end
% 
%     if action(i) == correctAction
%         rewardVector(i) = rewards.goodMove * (action(i) ~= 0) + rewards.goodMove2 * (action(i) == 0);
%     elseif action(i) == 0
%         rewardVector(i) = rewards.wrongStop;
%     else
%         rewardVector(i) = rewards.dirInverse;
%     end
% 
%     slope = posFlex(i) - previousPosFlex(i);
%     rewardVector(i) = rewardVector(i) + rewards.smoothnessPenalty * sqrt(abs(slope));
% 
%     if abs(slope) > 0.01 && abs(slope) < 0.5
%         rewardVector(i) = rewardVector(i) + rewards.efficiencyBonus;
%     end
% end
% 
% previousPosFlex = posFlex;
% 
% % Penalización por inactividad
% if all(action == 0) && correctAction ~= 0
%     inactiveSteps = inactiveSteps + 1;
%     penalty = rewards.inactivityPenalty * inactiveSteps;
%     rewardVector = rewardVector + penalty;
% else
%     inactiveSteps = 0;
% end
% 
% if any(action ~= 0)
%     rewardVector = rewardVector + rewards.moveIncentive;
% end
% 
% distance = abs(posFlex - flexConv(end, :));
% rewardVector = rewardVector - sqrt(distance) .* opts.k;
% 
% precisionMask = distance < 0.05;
% rewardVector(precisionMask) = rewardVector(precisionMask) + rewards.precisionBonus / 2;
% 
% baseReward = mean(rewardVector);
% 
% %% 📐 Shaping: función de potencial y ajuste
% range = [4092 2046 1023 2046];  % rangos de normalización por motor
% normDiff = (posFlex - flexConv(end, :)) ./ range;
% phiCurrent = -log(1 + mean(normDiff .^ 2));  % función de potencial logarítmica
% 
% shapingTerm = baseShapingGain * (gamma * phiCurrent - previousPhi);
% previousPhi = phiCurrent;
% 
% reward = baseReward + shapingTerm;
% end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% persistent previousPosFlex inactiveSteps previousPhi
% 
% if isempty(previousPosFlex), previousPosFlex = zeros(size(action)); end
% if isempty(inactiveSteps), inactiveSteps = 0; end
% if isempty(previousPhi), previousPhi = 0; end
% 
% %% Configuración
% opts.k = 3;
% gamma = 0.99;
% baseShapingGain = 6;
% clipLimit = 100;  % Límite para el clipping
% 
% % Recompensas
% rewards.dirInverse = -5;
% rewards.wrongStop = -15;
% rewards.goodMove = 15;
% rewards.goodMove2 = 1;
% rewards.inactivityPenalty = -2;
% rewards.moveIncentive = 5;
% rewards.precisionBonus = 10;
% rewards.smoothnessPenalty = -3;
% rewards.efficiencyBonus = 3;
% 
% rewardVector = zeros(1, 4);
% 
% %% Estado actual
% if this.c == 1
%     flexConv = this.flexJoined_scaler(reduceFlexDimension(this.flexData));
% else
%     flexConv = this.flexConvertedLog{this.c - 1};
% end
% pos = this.motorData(end, :);
% posFlex = this.flexJoined_scaler(encoder2Flex(pos));
% 
% %% Recompensas heurísticas motor por motor
% for i = 1:length(action)
%     if posFlex(i) < flexConv(end, i)
%         correctAction = 1;
%     elseif posFlex(i) > flexConv(end, i)
%         correctAction = -1;
%     else
%         correctAction = 0;
%     end
% 
%     if action(i) == correctAction
%         rewardVector(i) = rewards.goodMove * (action(i) ~= 0) + rewards.goodMove2 * (action(i) == 0);
%     elseif action(i) == 0
%         rewardVector(i) = rewards.wrongStop;
%     else
%         rewardVector(i) = rewards.dirInverse;
%     end
% 
%     % Suavidad
%     slope = posFlex(i) - previousPosFlex(i);
%     rewardVector(i) = rewardVector(i) + rewards.smoothnessPenalty * sqrt(abs(slope));
% 
%     % Eficiencia
%     if abs(slope) > 0.01 && abs(slope) < 0.5
%         rewardVector(i) = rewardVector(i) + rewards.efficiencyBonus;
%     end
% end
% 
% previousPosFlex = posFlex;
% 
% %% Penalización por inactividad
% if all(action == 0) && any(abs(posFlex - flexConv(end, :)) > 0.05)
%     inactiveSteps = inactiveSteps + 1;
%     penalty = rewards.inactivityPenalty * inactiveSteps;
%     rewardVector = rewardVector + penalty;
% else
%     inactiveSteps = 0;
% end
% 
% % Incentivar movimiento
% if any(action ~= 0)
%     rewardVector = rewardVector + rewards.moveIncentive;
% end
% 
% % Penalización por distancia
% distance = abs(posFlex - flexConv(end, :));
% rewardVector = rewardVector - sqrt(distance) .* opts.k;
% 
% % Bonificación por precisión
% precisionMask = distance < 0.05;
% rewardVector(precisionMask) = rewardVector(precisionMask) + rewards.precisionBonus / 2;
% 
% %% Recompensa base
% baseReward = mean(rewardVector);
% 
% %% Shaping con función de potencial logarítmica
% range = [4092 2046 1023 2046];  % rangos de normalización por motor
% normDiff = (posFlex - flexConv(end, :)) ./ range;
% phiCurrent = -log(1 + mean(normDiff .^ 2));
% 
% shapingTerm = baseShapingGain * (gamma * phiCurrent - previousPhi);
% previousPhi = phiCurrent;
% 
% rewardRaw = baseReward + shapingTerm;
% 
% %% Clipping suave
% reward = clipLimit * tanh(rewardRaw / clipLimit);
% end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% persistent previousPosFlex inactiveSteps previousPhi performanceWindow
% 
% if isempty(previousPosFlex), previousPosFlex = zeros(size(action)); end
% if isempty(inactiveSteps), inactiveSteps = 0; end
% if isempty(previousPhi), previousPhi = 0; end
% if isempty(performanceWindow), performanceWindow = zeros(1, 50); end
% 
% %% Parámetros
% opts.k = 3;
% gamma = 0.99;
% baseShapingGain = 6;
% clipLimit = 100;
% 
% rewards = struct( ...
%     "dirInverse", -5, ...
%     "wrongStop", -15, ...
%     "goodMove", 15, ...
%     "goodMove2", 1, ...
%     "inactivityPenalty", -2, ...
%     "moveIncentive", 5, ...
%     "precisionBonus", 10, ...
%     "smoothnessPenalty", -3, ...
%     "efficiencyBonus", 3, ...
%     "energyPenaltyWeight", -1.5 ...
% );
% 
% rewardVector = zeros(1, 4);
% 
% %% Estado actual
% if this.c == 1
%     flexConv = this.flexJoined_scaler(reduceFlexDimension(this.flexData));
% else
%     flexConv = this.flexConvertedLog{this.c - 1};
% end
% pos = this.motorData(end, :);
% posFlex = this.flexJoined_scaler(encoder2Flex(pos));
% 
% %% Recompensas por acción motor por motor
% for i = 1:length(action)
%     if posFlex(i) < flexConv(end, i)
%         correctAction = 1;
%     elseif posFlex(i) > flexConv(end, i)
%         correctAction = -1;
%     else
%         correctAction = 0;
%     end
% 
%     if action(i) == correctAction
%         rewardVector(i) = rewards.goodMove * (action(i) ~= 0) + rewards.goodMove2 * (action(i) == 0);
%     elseif action(i) == 0
%         rewardVector(i) = rewards.wrongStop;
%     else
%         rewardVector(i) = rewards.dirInverse;
%     end
% 
%     % Suavidad y eficiencia
%     slope = posFlex(i) - previousPosFlex(i);
%     rewardVector(i) = rewardVector(i) + rewards.smoothnessPenalty * sqrt(abs(slope));
%     if abs(slope) > 0.01 && abs(slope) < 0.5
%         rewardVector(i) = rewardVector(i) + rewards.efficiencyBonus;
%     end
% end
% previousPosFlex = posFlex;
% 
% %% Penalización por inactividad
% if all(action == 0) && any(abs(posFlex - flexConv(end, :)) > 0.05)
%     inactiveSteps = inactiveSteps + 1;
%     penalty = rewards.inactivityPenalty * inactiveSteps;
%     rewardVector = rewardVector + penalty;
% else
%     inactiveSteps = 0;
% end
% 
% %% Incentivo por moverse
% if any(action ~= 0)
%     rewardVector = rewardVector + rewards.moveIncentive;
% end
% 
% %% Penalización por distancia
% distance = abs(posFlex - flexConv(end, :));
% scaledDist = sqrt(distance);
% rewardVector = rewardVector - scaledDist .* opts.k;
% 
% %% Bonificación por precisión (Gauss adaptativa)
% sigma = max(0.01, mean(distance) * 0.5);  % Adaptar la sigma a la dificultad actual
% precisionBonus = rewards.precisionBonus * exp(-(distance.^2) / (2 * sigma^2));
% rewardVector = rewardVector + precisionBonus;
% 
% %% Penalización por energía
% energyPenalty = rewards.energyPenaltyWeight * mean(abs(action));
% rewardVector = rewardVector + energyPenalty;
% 
% %% Recompensa base
% baseReward = mean(rewardVector);
% 
% %% Reward shaping
% range = [4092 2046 1023 2046];
% normDiff = (posFlex - flexConv(end, :)) ./ range;
% phiCurrent = -log(1 + mean(normDiff .^ 2));
% 
% % Shaping adaptativo con performance reciente
% progressDelta = mean(previousPhi - phiCurrent);  % puede ser negativo
% performanceWindow = [performanceWindow(2:end), progressDelta];
% progressFactor = min(1.5, max(0.1, mean(performanceWindow) * 50)); % controlado
% shapingGain = baseShapingGain * progressFactor;
% 
% % Shaping term
% shapingTerm = shapingGain * (gamma * phiCurrent - previousPhi);
% previousPhi = phiCurrent;
% 
% rewardRaw = baseReward + shapingTerm;
% 
% %% Clipping suave
% reward = clipLimit * tanh(rewardRaw / clipLimit);
% end
% --------------------------------------------------------------------------
% --------------------------------------------------------------------------
% 
% persistent previousPosFlex inactiveSteps previousPhi
% 
% if isempty(previousPosFlex), previousPosFlex = zeros(size(action)); end
% if isempty(inactiveSteps), inactiveSteps = 0; end
% if isempty(previousPhi), previousPhi = 0; end
% 
% %% Parámetros de recompensa
% opts.k = 3;  % penalización por distancia
% opts.gamma = 0.99;
% opts.shapingGain = 6;
% opts.clipLimit = 100;
% range = [4092 2046 1023 2046];  % rango para normalización de motores
% 
% rewards.dirInverse = -5;
% rewards.wrongStop = -15;
% rewards.goodMove = 15;
% rewards.goodMove2 = 1;
% rewards.inactivityPenalty = -2;
% rewards.moveIncentive = 5;
% rewards.precisionBonus = 10;
% rewards.smoothnessPenalty = -3;
% rewards.efficiencyBonus = 3;
% 
% rewardVector = zeros(1, length(action));
% 
% %% Estado actual
% if this.c == 1
%     flexConv = this.flexJoined_scaler(reduceFlexDimension(this.flexData));
% else
%     flexConv = this.flexConvertedLog{this.c - 1};
% end
% pos = this.motorData(end, :);
% posFlex = this.flexJoined_scaler(encoder2Flex(pos));
% 
% %% Recompensa heurística motor a motor
% for i = 1:length(action)
%     % Determinar dirección correcta
%     if posFlex(i) < flexConv(end, i)
%         correctAction = 1;
%     elseif posFlex(i) > flexConv(end, i)
%         correctAction = -1;
%     else
%         correctAction = 0;
%     end
% 
%     % Aplicar recompensa según dirección
%     if action(i) == correctAction
%         rewardVector(i) = rewards.goodMove * (action(i) ~= 0) + rewards.goodMove2 * (action(i) == 0);
%     elseif action(i) == 0
%         rewardVector(i) = rewards.wrongStop;
%     else
%         rewardVector(i) = rewards.dirInverse;
%     end
% 
%     % Suavidad y eficiencia
%     slope = posFlex(i) - previousPosFlex(i);
%     rewardVector(i) = rewardVector(i) + rewards.smoothnessPenalty * sqrt(abs(slope));
%     if abs(slope) > 0.01 && abs(slope) < 0.5
%         rewardVector(i) = rewardVector(i) + rewards.efficiencyBonus;
%     end
% end
% 
% previousPosFlex = posFlex;
% 
% %% Penalización acumulada por inactividad
% if all(action == 0) && any(abs(posFlex - flexConv(end, :)) > 0.05)
%     inactiveSteps = inactiveSteps + 1;
%     penalty = rewards.inactivityPenalty * inactiveSteps;
%     rewardVector = rewardVector + penalty;
% else
%     inactiveSteps = 0;
% end
% 
% %% Incentivo por moverse
% if any(action ~= 0)
%     rewardVector = rewardVector + rewards.moveIncentive;
% end
% 
% %% Penalización por distancia (raíz cuadrada)
% distance = abs(posFlex - flexConv(end, :));
% rewardVector = rewardVector - sqrt(distance) * opts.k;
% 
% %% Bonificación por precisión
% precisionMask = distance < 0.05;
% rewardVector(precisionMask) = rewardVector(precisionMask) + rewards.precisionBonus / 2;
% 
% %% Recompensa base
% baseReward = mean(rewardVector);
% 
% %% Reward shaping: potencial cuadrático normalizado
% normalizedDiff = (posFlex - flexConv(end, :)) ./ range;
% phiCurrent = -mean(normalizedDiff .^ 2);
% shapingTerm = opts.shapingGain * (opts.gamma * phiCurrent - previousPhi);
% previousPhi = phiCurrent;
% 
% %% Suma total con shaping
% rewardRaw = baseReward + shapingTerm;
% 
% %% Clipping suave con tanh
% reward = opts.clipLimit * tanh(rewardRaw / opts.clipLimit);
% end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% persistent previousPosFlex inactiveSteps previousPhi stepCount
% 
% if isempty(previousPosFlex), previousPosFlex = zeros(size(action)); end
% if isempty(inactiveSteps), inactiveSteps = 0; end
% if isempty(previousPhi), previousPhi = 0; end
% if isempty(stepCount), stepCount = 0; end
% 
% stepCount = stepCount + 1;
% 
% %Parámetros de recompensa
% opts.k = 2.5;                      % penalización de distancia
% opts.gamma = 0.99;                % factor de descuento
% opts.baseShapingGain = 6;        % ganancia base del shaping
% opts.clipLimit = 100;            % límite base de clipping
% range = [4092 2046 1023 2046];    % rango para normalizar errores
% 
% %Recompensas
% rewards = struct( ...
%     'dirInverse', -5, ...
%     'wrongStop', -15, ...
%     'goodMove', 15, ...
%     'goodMove2', 2, ...
%     'inactivityPenalty', -2, ...
%     'moveIncentive', 4, ...
%     'precisionBonus', 10, ...
%     'smoothnessPenalty', -2, ...
%     'efficiencyBonus', 3, ...
%     'stabilityBonus', 4 ...
% );
% 
% rewardVector = zeros(1, length(action));
% 
% %Estado actual
% if this.c == 1
%     flexConv = this.flexJoined_scaler(reduceFlexDimension(this.flexData));
% else
%     flexConv = this.flexConvertedLog{this.c - 1};
% end
% pos = this.motorData(end, :);
% posFlex = this.flexJoined_scaler(encoder2Flex(pos));
% 
% %Recompensas por motor
% for i = 1:length(action)
%     if posFlex(i) < flexConv(end, i)
%         correctAction = 1;
%     elseif posFlex(i) > flexConv(end, i)
%         correctAction = -1;
%     else
%         correctAction = 0;
%     end
% 
%     if action(i) == correctAction
%         rewardVector(i) = rewards.goodMove * (action(i) ~= 0) + rewards.goodMove2 * (action(i) == 0);
%     elseif action(i) == 0
%         rewardVector(i) = rewards.wrongStop;
%     else
%         rewardVector(i) = rewards.dirInverse;
%     end
% 
%     slope = posFlex(i) - previousPosFlex(i);
%     rewardVector(i) = rewardVector(i) + rewards.smoothnessPenalty * sqrt(abs(slope));
%     if abs(slope) > 0.01 && abs(slope) < 0.4
%         rewardVector(i) = rewardVector(i) + rewards.efficiencyBonus;
%     end
% end
% 
% previousPosFlex = posFlex;
% 
% %Penalización por inactividad
% if all(action == 0) && any(abs(posFlex - flexConv(end, :)) > 0.05)
%     inactiveSteps = inactiveSteps + 1;
%     penalty = rewards.inactivityPenalty * inactiveSteps;
%     rewardVector = rewardVector + penalty;
% else
%     inactiveSteps = 0;
% end
% 
% %Bonificación por moverse
% if any(action ~= 0)
%     rewardVector = rewardVector + rewards.moveIncentive;
% end
% 
% %Penalización por distancia (suavizada)
% distance = abs(posFlex - flexConv(end, :));
% rewardVector = rewardVector - sqrt(distance) * opts.k;
% 
% %Bonificación por precisión
% precisionMask = distance < 0.03;
% rewardVector(precisionMask) = rewardVector(precisionMask) + rewards.precisionBonus;
% 
% %Bonificación por estabilidad (todos los motores en sincronía)
% if std(distance) < 0.01
%     rewardVector = rewardVector + rewards.stabilityBonus;
% end
% 
% %Recompensa base
% baseReward = mean(rewardVector);
% 
% %Shaping con función de potencial logarítmica
% normalizedDiff = (posFlex - flexConv(end, :)) ./ range;
% phiCurrent = -log(1 + mean(normalizedDiff .^ 2));
% 
% %Ganancia adaptativa que decae suavemente en el tiempo
% shapingGain = opts.baseShapingGain * exp(-0.0002 * stepCount);
% 
% shapingTerm = shapingGain * (opts.gamma * phiCurrent - previousPhi);
% previousPhi = phiCurrent;
% 
% %Reward shaping + Clipping dinámico
% rewardRaw = baseReward + shapingTerm;
% reward = opts.clipLimit * tanh(rewardRaw / opts.clipLimit);
% 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%VERSION MEJORADA NUEVA
%%%%%%RECOMPENSA%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% persistent previousPosFlex inactiveSteps previousPhi
% 
% if isempty(previousPosFlex), previousPosFlex = zeros(size(action)); end
% if isempty(inactiveSteps), inactiveSteps = 0; end
% if isempty(previousPhi), previousPhi = 0; end
% 
% % Parámetros generales
% opts.k = 3;                    % Penalización por distancia
% opts.gamma = 0.99;
% opts.shapingGain = 6;
% opts.clipLimit = 100;
% opts.oscPenalty = 1.5;         % Penalización por oscilaciones
% range = [4092 2046 1023 2046]; % Rango de normalización por motor
% weights = [0.3 0.25 0.25 0.2]; % Pesos por motor
% 
% % Recompensas
% rewards = struct( ...
%     'dirInverse', -5, ...
%     'wrongStop', -15, ...
%     'goodMove', 15, ...
%     'goodMove2', 1, ...
%     'inactivityPenalty', -2, ...
%     'moveIncentive', 5, ...
%     'precisionBonus', 10, ...
%     'smoothnessPenalty', -3, ...
%     'efficiencyBonus', 3, ...
%     'finalPrecisionBonus', 15 ...
% );
% 
% rewardVector = zeros(1, length(action));
% 
% % Obtener estado actual
% if this.c == 1
%     flexConv = this.flexJoined_scaler(reduceFlexDimension(this.flexData));
% else
%     flexConv = this.flexConvertedLog{this.c - 1};
% end
% pos = this.motorData(end, :);
% posFlex = this.flexJoined_scaler(encoder2Flex(pos));
% 
% % Recompensa heurística motor a motor
% directionChanges = 0;
% for i = 1:length(action)
%     % Dirección correcta
%     if posFlex(i) < flexConv(end, i)
%         correctAction = 1;
%     elseif posFlex(i) > flexConv(end, i)
%         correctAction = -1;
%     else
%         correctAction = 0;
%     end
% 
%     % Recompensa base
%     if action(i) == correctAction
%         rewardVector(i) = rewards.goodMove * (action(i) ~= 0) + rewards.goodMove2 * (action(i) == 0);
%     elseif action(i) == 0
%         rewardVector(i) = rewards.wrongStop;
%     else
%         rewardVector(i) = rewards.dirInverse;
%     end
% 
%     % Suavidad y eficiencia
%     slope = posFlex(i) - previousPosFlex(i);
%     rewardVector(i) = rewardVector(i) + rewards.smoothnessPenalty * sqrt(abs(slope));
%     if abs(slope) > 0.01 && abs(slope) < 0.5
%         rewardVector(i) = rewardVector(i) + rewards.efficiencyBonus;
%     end
% 
%     % Conteo de cambios de dirección
%     if sign(slope) ~= sign(previousPosFlex(i) - flexConv(end, i))
%         directionChanges = directionChanges + 1;
%     end
% end
% 
% previousPosFlex = posFlex;
% 
% % Penalización por inactividad
% if all(action == 0) && any(abs(posFlex - flexConv(end, :)) > 0.05)
%     inactiveSteps = inactiveSteps + 1;
%     rewardVector = rewardVector + rewards.inactivityPenalty * inactiveSteps;
% else
%     inactiveSteps = 0;
% end
% 
% % Incentivo por moverse
% if any(action ~= 0)
%     rewardVector = rewardVector + rewards.moveIncentive;
% end
% 
% % Penalización por distancia
% distance = abs(posFlex - flexConv(end, :));
% rewardVector = rewardVector - sqrt(distance) * opts.k;
% 
% % Bonificación por precisión parcial
% precisionMask = distance < 0.05;
% rewardVector(precisionMask) = rewardVector(precisionMask) + rewards.precisionBonus / 2;
% 
% % Bonificación adicional si el error promedio final es muy bajo
% if mean(distance) < 0.03
%     rewardVector = rewardVector + rewards.finalPrecisionBonus;
% end
% 
% % Recompensa base total
% baseReward = mean(rewardVector);
% 
% % Función de potencial logarítmica ponderada
% normDiff = (posFlex - flexConv(end, :)) ./ range;
% phiCurrent = -log(1 + sum(weights .* (normDiff .^ 2)));
% 
% % Shaping con delta de potencial
% shapingTerm = opts.shapingGain * (opts.gamma * phiCurrent - previousPhi);
% previousPhi = phiCurrent;
% 
% % Penalización por oscilaciones
% oscPenalty = -opts.oscPenalty * directionChanges;
% 
% % Total sin clipping
% rewardRaw = baseReward + shapingTerm + oscPenalty;
% 
% % Clipping condicional
% if abs(rewardRaw) < opts.clipLimit
%     reward = rewardRaw;
% else
%     reward = opts.clipLimit * sign(rewardRaw);
% end
% end


    function [reward, rewardVector, action] = legacy_distanceRewarding(this, action)
% =========================================================================
% V6: Phase-aware PBRS + Soft Saturation  (diseñada para superar V5)
% Firma original: [reward, rewardVector, action] = legacy_distanceRewarding(this, action)
% =========================================================================

    % -------- Persistentes (como en tus versiones) --------
    persistent previousPosFlex previousPhi prevDirSign stallCount
    if isempty(previousPhi), previousPhi = 0; end
    if isempty(stallCount),  stallCount  = 0; end

    % -------- 1) Leer estado/objetivo desde "this" --------
    % Ajusta los nombres si en tu clase son diferentes.
    posFlex  = getFirstProp(this, {'posFlex','PosFlex','currentPosFlex','flexState','stateFlex'});
    flexConv = getFirstProp(this, {'flexConv','FlexConv','targetFlex','goalFlex','refFlex'});

    posFlex  = posFlex(:);
    flexConv = flexConv(:);
    n = numel(posFlex);

    if isempty(previousPosFlex), previousPosFlex = posFlex; end
    if isempty(prevDirSign),     prevDirSign     = zeros(n,1); end

    % -------- 2) Parámetros (con defaults seguros) --------
    gamma = getFirstProp(this, {'gamma','Gamma','discountFactor','DiscountFactor'}, 0.99);

    % Pesos por actuador (si ya tienes weights en tu clase, se usan)
    w = getFirstProp(this, {'weights','w','motorWeights','W'}, ones(n,1));
    w = w(:);
    if numel(w) ~= n, w = ones(n,1); end

    % Puedes tener struct opts/rewards en tu clase; si existe se usa
    opts = getFirstProp(this, {'opts','rewardOpts','rewardOptions'}, struct());
    rewards = getFirstProp(this, {'rewards','rewardParams'}, struct()); %#ok<NASGU>

    % Defaults (ajusta según tu escala 0..1 o grados)
    huberDelta     = getFieldOr(opts,'huberDelta',     0.05);  % robustez
    stabilityEps   = getFieldOr(opts,'stabilityEps',   0.03);  % umbral de "ya llegué"
    betaStability  = getFieldOr(opts,'betaStability',  0.50);  % cuánto vale sostener estable
    lambdaOsc      = getFieldOr(opts,'lambdaOsc',      0.02);  % castigo oscilación
    lambdaAct      = getFieldOr(opts,'lambdaAct',      0.01);  % castigo esfuerzo
    stallTol       = getFieldOr(opts,'stallTol',       1e-3);  % mejora mínima
    stallMax       = getFieldOr(opts,'stallMax',       8);     % pasos sin progreso
    stallPenalty   = getFieldOr(opts,'stallPenalty',   0.05);  % penalización por estancamiento
    stepCost       = getFieldOr(opts,'stepCost',       0.0);   % costo por paso (opcional)
    Lsat           = getFieldOr(opts,'Lsat',           1.0);   % saturación suave

    % -------- 3) Reward "de tarea" (opcional) --------
    % Si tu entorno tiene flags explícitos (success/fail), conecta aquí.
    r_task = 0;

    % Ejemplo: "éxito" si todos los errores están bajo umbral
    e = posFlex - flexConv;
    isStableNow = all(abs(e) < stabilityEps);
    if isStableNow
        r_task = r_task + getFieldOr(opts,'R_success', 0.0);
    end

    % -------- 4) Potencial Φ(s): progreso robusto + estabilidad --------
    % Φ = -Σ w_i * Huber(e_i) + beta * I(estabilidad)
    phiProgress = -sum(w .* huberLoss(e, huberDelta));
    phiStab     = betaStability * double(isStableNow);
    phiCurrent  = phiProgress + phiStab;

    % PBRS shaping
    shapingTerm = gamma * phiCurrent - previousPhi;

    % -------- 5) Penalización por oscilación (chattering) --------
    dir = sign(posFlex - previousPosFlex);                 % dirección real del cambio
    dir(dir==0) = prevDirSign(dir==0);                     % evita ceros
    directionChanges = sum(dir ~= prevDirSign);
    p_osc = -lambdaOsc * directionChanges;

    % -------- 6) Penalización por esfuerzo --------
    action = action(:);
    p_act = -lambdaAct * sum(abs(action));

    % -------- 7) Penalización por estancamiento (stall) --------
    prevErr = norm(previousPosFlex - flexConv, 1);
    currErr = norm(posFlex - flexConv, 1);
    improvement = prevErr - currErr;

    if improvement < stallTol
        stallCount = stallCount + 1;
    else
        stallCount = max(stallCount - 1, 0);
    end

    p_stall = 0;
    if stallCount >= stallMax
        p_stall = -stallPenalty;
    end

    % -------- 8) Reward total (sin clipping duro) --------
    r_raw = r_task + shapingTerm + p_osc + p_act + p_stall - stepCost;

    % Saturación suave (mejor que clipping para “superar V5”)
    reward = Lsat * tanh( r_raw / max(Lsat, eps) );

    % -------- 9) rewardVector por actuador --------
    % Distribuimos contribución por motor (útil para debug/plots).
    % Base por motor: -w_i * huber(e_i)  (progreso)
    % + un pequeño share del shaping global (para que sea interpretable)
    rv_progress = -(w .* huberLoss(e, huberDelta));
    rv_shapeShare = (shapingTerm / max(n,1)) * ones(n,1);

    % Penalizaciones globales repartidas (solo para lectura)
    rv_penShare = ((p_osc + p_act + p_stall - stepCost) / max(n,1)) * ones(n,1);

    rewardVector = rv_progress + rv_shapeShare + rv_penShare;

    % -------- 10) Update persistentes --------
    previousPosFlex = posFlex;
    previousPhi     = phiCurrent;
    prevDirSign     = dir;

end

% ================= Helpers =================

function val = getFirstProp(obj, names, default)
    if nargin < 3, default = []; end
    val = default;
    for k = 1:numel(names)
        nm = names{k};
        try
            if isprop(obj, nm)
                val = obj.(nm);
                if ~isempty(val), return; end
            end
        catch
            % ignore y sigue
        end
        try
            if isfield(obj, nm) %#ok<ISFLD>
                val = obj.(nm);
                if ~isempty(val), return; end
            end
        catch
        end
    end
end

function v = getFieldOr(s, field, default)
    v = default;
    if isstruct(s) && isfield(s, field)
        v = s.(field);
    end
end

function y = huberLoss(x, delta)
    ax = abs(x);
    y = zeros(size(x));
    q = ax <= delta;
    y(q)  = 0.5 * (x(q).^2);
    y(~q) = delta * (ax(~q) - 0.5*delta);
end