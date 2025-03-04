return function(plant, params)
    local plant_name_xy = plant.name .. " at (" .. plant.x .. ", " .. plant.y .. ")"
    local job_name = "Watering " .. plant_name_xy

    if not plant.age then
        toast(plant_name_xy .. " has not been planted yet. Skipping.", "warn")
        return
    end

    -- Get water curve and water amount in mL
    local water_curve, water_ml
    if plant.water_curve_id then
        water_curve = get_curve(plant.water_curve_id)
        water_ml = water_curve.day(plant.age)
    else
        toast(plant.name .. " at location (" .. plant.x .. ", " .. plant.y .. ", " .. plant.z .. ") has no assigned water curve. Watering 50ml", "warn")
        dispense(50)
        return
    end

    -- Move to the plant
    set_job(job_name, { status = "Moving" })
    move{ x = plant.x - 50, y = plant.y, z = -100 } -- compensate for water nozzle size on x axis

    -- Water the plant
    set_job(job_name, { status = "Watering", percent = 50 })
    send_message("info", "Watering " .. plant.age .. " day old " .. plant_name_xy .. " " .. water_ml .. "mL")
    
    -- dispense(water_ml, params)
    
    numRepeatsFull = math.floor(water_ml/50) -- calculate how many pulses of 50ml are required
    --toast("numRepeatsFull: " .. numRepeatsFull, "info")

    finalComplete = math.fmod(water_ml, 50) -- calculate how much is left after 50ml pulses
    --toast("finalComplete: " .. finalComplete, "info")

    toast(plant.name .. " (" .. plant.age .. " days old)" .. " should be watered " .. water_ml .. "ml. " .. numRepeatsFull .. " pulses of 50 ml and 1 pulse of " .. finalComplete .. " ml.")

    for i = 1,numRepeatsFull do -- repeats the amount of number of pulses
        dispense(50)
        wait(1500)
    end 

    --toast("dispensing what's left", "info")
    dispense(finalComplete) -- dispense what is left (<50 ml)

    complete_job(job_name)
end
