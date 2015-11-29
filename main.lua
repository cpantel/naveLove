local nave
local sonido_motor
local explosion
local fuego_vertical
local fuego_der
local fuego_izq
local x
local y
local speed_x
local speed_y
local ancho
local alto
local gordura
local ver_fantasma
local fantasma_abajo
local fantasma_arriba
local fantasma_der
local fantasma_izq
local fantasma_cruzado
local mostrar_fuego_vertical
local mostrar_fuego_vertical_largo
local mostrar_fuego_der
local mostrar_fuego_izq
local destruido
local detenido
local evaluando
local combustible
local sonido_explosion
local sonido_motor
local mostrar_sonido
local recien_destruido
local x1
local x2
local x3
local x4
local x5
local xn
local xa
local elapsed

function love.load()
        
	nave = love.graphics.newImage("nave.png")
	fuego_vertical = love.graphics.newImage("fuego_vertical.png")
	fuego_vertical_largo = love.graphics.newImage("fuego_vertical_largo.png")
	fuego_izq = love.graphics.newImage("fuego_izq.png")
	fuego_der = love.graphics.newImage("fuego_der.png")
	explosion = love.graphics.newImage("explosion.png")

	sonido_motor = love.audio.newSource("motor.ogg", "stream")
	sonido_motor:setLooping(true)
	sonido_explosion = love.audio.newSource("explosion.ogg", "stream")
	recien_destruido = 0
	xn = love.joystick.getNumJoysticks()
	xa = love.joystick.getNumAxes(1)
	speed_x = 80
	speed_y = 10
	ancho = love.graphics.getWidth()
	alto = love.graphics.getHeight()
	gordura = 32
	x = 50
	y = gordura * 2
	destruido = false
	detenido = false
	combustible = 1000
	elapsed = love.timer.getTime()
end

function ajustarCombustible(dt, boost)
	local peso = 500 + combustible
	if boost == 2 then boost = 3 end
	combustible = combustible - (dt * peso * boost / 25)
end

function love.update(dt)
	if not destruido and not detenido then
		mostrar_fuego_vertical = false
		mostrar_fuego_vertical_largo = false
		mostrar_fuego_der = false
		mostrar_fuego_izq = false
		mostrar_sonido = false
		x1,x2,x3,x4,x5 = love.joystick.getAxes(1)
		
		if combustible > 0 then
			if love.keyboard.isDown("right") or x1 == 1 then
				speed_x = speed_x + 1
				mostrar_fuego_izq = true
				ajustarCombustible(dt, 1)
				mostrar_sonido = true
			elseif love.keyboard.isDown("left") or x1 == -1 then
				speed_x = speed_x - 1
				mostrar_fuego_der = true
				ajustarCombustible(dt, 1)
				mostrar_sonido = true
			end

			if love.keyboard.isDown("up") or x2 < -0.05 then
				local boost = 1
				if love.keyboard.isDown("lshift") or x2 < -0.9 then
					boost = 2
					mostrar_fuego_vertical_largo = true
				else
					mostrar_fuego_vertical = true
				end
				speed_y = speed_y - (1 * boost)
				mostrar_sonido = true
				ajustarCombustible(dt, boost)
			end
		end
		x = x + (speed_x * dt)
		y = y + (speed_y * dt)
		speed_y = speed_y + (50 * dt)
		
		if ( x <= 0 ) or ( x >= ancho - gordura ) then
			destruido = true
			return
		end
		if  (y <= 0 ) or (y >= alto - gordura) then
			destruido = true
			return
		end
		evaluando = false
		if  (x <= 500 and x >= 400 and y >= alto - 10 - gordura)  then
			evaluarImpacto()
		end
	end
end

function evaluarImpacto()
	evaluando = true
	if (math.abs(speed_y) > 25 or math.abs(speed_x) > 35) then
		destruido = true
	else
		detenido = true
		speed_x = 0
		speed_y = 0
	end
end

function love.keypressed(key)
   if key == "escape" then
      love.event.push("quit")
   end
end 
   
function debug()
	local margen = 50
	local linea = 300
        local joystick = string.format("Impulso lateral: %3.3f vertical %3.3f", x1, x2)
	local posicion = string.format("Posición horizontal: %3d vertical: %3d", x ,y )
	local velocidad = string.format("Velocidad horizontal: %3d vertical: %3d", speed_x ,speed_y )
	local reserva = string.format("Combustible: %d", combustible )
	local stats = string.format("FPS: %d Tiempo: %3.3d",  love.timer.getFPS(), love.timer.getTime() - elapsed)
	love.graphics.print("TELEMETRÍA",margen, linea)
	love.graphics.print(joystick, margen , linea + 20)
	love.graphics.print(posicion , margen, linea + 30)
	love.graphics.print(velocidad , margen, linea + 40)
	love.graphics.print(reserva, margen, linea + 50)
	love.graphics.print(stats, 20,20)
	
end



function love.draw()
	love.graphics.line( 400, alto - 10, 500, alto - 10)
	if recien_destruido == 1 then
		love.audio.play(sonido_explosion)
		recien_destruido = 2
		love.audio.stop(sonido_motor)
	end
	if destruido then
		local correccion = (82 - gordura) / 2
		love.graphics.draw(explosion, x - correccion, y - (82 - correccion))
		love.audio.stop(sonido_motor)
		if recien_destruido == 0 then
			recien_destruido = 1
		end
	else
		
		love.graphics.draw(nave, x, y)
		if detenido then
			love.audio.stop(sonido_motor)
		else
			
			if mostrar_fuego_der then
				love.graphics.draw(fuego_der, x + gordura, y + (gordura /2) - 8)
			end
			if mostrar_fuego_izq then
				love.graphics.draw(fuego_izq, x - 16, y + (gordura /2) - 8)
			end

			if mostrar_fuego_vertical then
				love.graphics.draw(fuego_vertical, x + (gordura /2) - 8, y + gordura)
			end
			if mostrar_fuego_vertical_largo then
				love.graphics.draw(fuego_vertical_largo, x + (gordura /2) - 8, y + gordura)
			end
			if mostrar_sonido then
				love.audio.play(sonido_motor)
			else
				love.audio.pause(sonido_motor)
			end
			
		end
	end
	debug()
end