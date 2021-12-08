within ;
model BouncingBall1D

  Modelica.SIunits.Position mass_s;
  Modelica.SIunits.Velocity mass_v;

  parameter Modelica.SIunits.Radius mass_radius = 0.1;
  parameter Modelica.SIunits.Position mass_s_start = 1.0;
  parameter Modelica.SIunits.Mass mass_m = 1.0;

  parameter Real damping = 0.9;

initial equation

  mass_s = mass_s_start;
  mass_v = 0.0;

equation

  der(mass_s) = mass_v;
  mass_m * der(mass_v) = -9.81 * mass_m;

  when mass_s < mass_radius then
    reinit(mass_v, -pre(mass_v)*damping);
  end when;

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end BouncingBall1D;
