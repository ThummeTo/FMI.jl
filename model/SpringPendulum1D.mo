within ;
model SpringPendulum1D
  parameter Modelica.SIunits.Position mass_s0 = 0.5;
  parameter Modelica.SIunits.Velocity mass_v0 = 0.0;
  Modelica.Mechanics.Translational.Components.Fixed fixed(s0=0.1)
                                                          annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-30,0})));
  Modelica.Mechanics.Translational.Components.Spring spring(c=10,
    s_rel0=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={0,0})));
  Modelica.Mechanics.Translational.Components.Mass mass(m=1,
    s(fixed=true, start=mass_s0),
    v(fixed=true, start=mass_v0))                            annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={30,0})));
equation
  connect(fixed.flange, spring.flange_a)
    annotation (Line(points={{-30,0},{-10,0}},
                                             color={0,127,0}));
  connect(spring.flange_b, mass.flange_a) annotation (Line(points={{10,0},{20,0}},
                                   color={0,127,0}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-60,-20},{60,20}})),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-60,-20},{60,
            20}})),
    uses(Modelica(version="3.2.3")));
end SpringPendulum1D;
