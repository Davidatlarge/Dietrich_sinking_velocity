#### particle sinking velocity in fluids 
#### using formulas from Dietrich 1982 (Water Resour. Res.)
#### or Stokes' Law
#### or Zhiyao et al. 2008 (Water Science and Engineering)
# by david.kaiser.82@gmail.com, github.com/davidatlarge
sinking.velocity.m.sec <- function(salinity, # practical salinity
                                   temperature, # in °C
                                   depth, # depth in m
                                   latitude, # latitude in °N, used to calculate pressure for density and gravity
                                   particle.density, # in kg/m^3 
                                   particle.diameter, # in m
                                   powers.p = 6, # powers roundness; defaults to 6 for perfectly round areas, including shperes
                                   shape.factor = 1, # should be Corey Shape factor for Dietrich and Janke E shape factor for Komar; defaults to 1 for spheres
                                   method = "dietrich" # calculation method, c("dietrich", "stokes", "zhiyao", "ahrens", "komar")
){
  # calculate gravity
  gravity <- marelac::gravity(lat = latitude, method = "Moritz")
  # calculate water parameters
  water.density <- marelac::sw_dens(S = salinity, t = temperature, P = seacarb::d2p(depth, lat = latitude)/10+1, method = "UNESCO") # value of d2p is dbar of pressure exerted by water, without air, hence /10 and +1 ; method="Gibbs" by default
  dynamic.viscosity <- marelac::viscosity(S = salinity, t = temperature, P = seacarb::d2p(depth, lat = latitude)/10+1) # viscosity in centipoise (cP); 1 cP = 0.001 kg·m−1·s−1
  dynamic.viscosity <- dynamic.viscosity / 1000 # factor 10^-3 to convert viscosity to [kg/m/s]
  kinematic.viscosity <- dynamic.viscosity / water.density 
  
  # calculate sinking velocity ...
  switch(method,
         "dietrich" = { # ... according to Dietrich 1982
           Dstar <- ((particle.density - water.density) * gravity * particle.diameter^3) / (water.density * kinematic.viscosity^2) # dimensionless size D*; introduces NaN for particles with lower density than water
           R1 <- -3.76715 + 1.92944*(log10(Dstar)) - 0.09815*(log10(Dstar))^2 - 0.00575*(log10(Dstar))^3 + 0.00056*(log10(Dstar))^4 # size and denisty effect
           R2 <- (log10(1-((1-shape.factor)/0.85))) - (1-shape.factor)^2.3*tanh(log10(Dstar)-4.6) + 0.3*(0.5-shape.factor)*(1-shape.factor)^2 * (log10(Dstar)-4.6) # shape effect
           R3 <- (0.65-((shape.factor/2.83) * tanh(log10(Dstar)-4.6)))^(1+(3.5-powers.p)/2.5) # roundness effect
           Wstar <- R3 * 10^(R1+R2) 
           sinking.velocity.m.sec <- ((Wstar*(particle.density-water.density) * gravity*kinematic.viscosity) / water.density)^(1/3) # introduced NaN for those particles that have no value for ESD because the dimensions were not measured
         },
         "stokes" = { # ... according to Stokes' Law
           if(particle.diameter > 0.0002) {warning("Particle diameter > 200 µm! \n Stokes' Law will overestimate sinking velocity! \n Use another method!", call. = FALSE)}
           sinking.velocity.m.sec <- (particle.diameter^2*gravity*(particle.density-water.density)) / (18*dynamic.viscosity)
           if(sinking.velocity.m.sec <= 0){sinking.velocity.m.sec <- NaN}
         }, 
         "zhiyao" = {
           delta <- particle.density/water.density-1 
           Dstar <- ((delta*gravity)/kinematic.viscosity^2)^(1/3)*particle.diameter # formula (5)
           sinking.velocity.m.sec <- (kinematic.viscosity/particle.diameter)*Dstar^3 * (38.1+0.93*Dstar^(12/7))^(-7/8) # formula (11)
         },
         "ahrens" = {
           Delta <- (particle.density - water.density) / water.density
           particle.diameter.cm <- particle.diameter * 100
           kinematic.viscosity.cm2.s <- kinematic.viscosity * 10000
           gravity.cm.s2 <- gravity * 100
           
           A <- Delta * gravity.cm.s2 * particle.diameter.cm^3 / kinematic.viscosity.cm2.s^2
           C1 <- 0.055 * tanh(12*A^-0.59 * exp(-0.0004*A))
           Ct <- 1.06 * tanh(0.016*A^0.50 * exp(-120/A))
    
           sinking.velocity.cm.sec <- C1 * Delta * gravity.cm.s2 * particle.diameter.cm^2 / kinematic.viscosity.cm2.s + # term associated with laminar flow
             Ct * sqrt(Delta * gravity.cm.s2 * particle.diameter.cm) # term associated with turbulent flow
           sinking.velocity.m.sec <- sinking.velocity.cm.sec / 100
         },
         "komar" = { # velocity for ellipsoid particles according to Komar 1980 (equation 2 in abstract)
           sinking.velocity.m.sec <- (1/18) * 
             (1/dynamic.viscosity) * 
             (particle.density - water.density) * 
             gravity * 
             particle.diameter^2 * 
             shape.factor^0.380 
         }
  )
  if(particle.density<water.density){
    warning(paste("Particle density (", round(particle.density), ") < water density (", round(water.density), 
                  ")! Particle will not sink! Returning NaN.", sep = ""),
            call. = FALSE)
  }
  return(sinking.velocity.m.sec)
}